#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="/opt/open5gs/install/bin"
CFG_DIR="/opt/open5gs/install/etc/open5gs"
LOG_DIR="/opt/open5gs/install/var/log/open5gs"

echo "[core] Preparing /dev/net/tun + ogstun..."

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
  mknod /dev/net/tun c 10 200
  chmod 666 /dev/net/tun
fi

ip tuntap add name ogstun mode tun 2>/dev/null || true
ip addr del 10.45.0.1/16 dev ogstun 2>/dev/null || true
ip addr add 10.45.1.1/24 dev ogstun 2>/dev/null || true
ip addr add 10.45.2.1/24 dev ogstun 2>/dev/null || true
ip addr add 10.45.3.1/24 dev ogstun 2>/dev/null || true
ip link set ogstun up 2>/dev/null || true

echo "[core] Starting MongoDB..."
mkdir -p /data/db
mongod --dbpath /data/db --bind_ip_all >/tmp/mongod.log 2>&1 &
sleep 5

echo "[core] Upserting 3 subscribers..."
mongosh --quiet --host localhost --port 27017 <<'MONGO_EOF'
use open5gs;

function upsertSubscriber(imsi, sst, dnn, ambrMbps, fiveQi, arpPriorityLevel) {
  const k   = "00112233445566778899aabbccddeeff";
  const opc = "63BFA50EE6523365FF14C1F45F88737D";

  // Build slice/session exactly like your "final subscriber list"
  const sliceObj = {
    _id: ObjectId(),
    sst: sst,
    sd: "000000",
    default_indicator: true,
    session: [
      {
        qos: {
          arp: {
            priority_level: arpPriorityLevel,
            pre_emption_capability: 1,
            pre_emption_vulnerability: 1
          },
          index: fiveQi
        },
        ambr: {
          downlink: { value: ambrMbps, unit: 2 },
          uplink:   { value: ambrMbps, unit: 2 }
        },
        _id: ObjectId(),
        name: dnn,
        type: 3,
        pcc_rule: []
      }
    ]
  };

  // Build smData exactly like your "final subscriber list"
  const smDataObj = {
    singleNssai: { sst: sst, sd: "000000" },
    dnnConfigurations: {}
  };

  smDataObj.dnnConfigurations[dnn] = {
    pduSessionTypes: {
      defaultSessionType: "IPV4V6",
      allowedSessionTypes: ["IPV4V6"]
    },
    sscModes: {
      defaultSscMode: "SSC_MODE_1",
      allowedSscModes: ["SSC_MODE_1"]
    },
    sessionAmbr: {
      uplink:   { value: ambrMbps, unit: "Mbps" },
      downlink: { value: ambrMbps, unit: "Mbps" }
    },
    "5gQosProfile": {
      "5qi": fiveQi,
      arp: {
        priorityLevel: arpPriorityLevel,
        preemptCap: "NOT_PREEMPT",
        preemptVuln: "NOT_PREEMPTABLE"
      }
    }
  };

  const doc = {
    imsi: imsi,
    subscriber_status: 0,
    network_access_mode: 2,
    access_restriction_data: 32,
    subscribed_rau_tau_timer: 12,
    security: { k: k, opc: opc, amf: "8000" },

    // ✅ REQUIRED by UDR/UDM (UE-AMBR) to avoid "No UE-AMBR"
    ambr: {
      downlink: { value: ambrMbps, unit: 2 },
      uplink:   { value: ambrMbps, unit: 2 }
    },

    // ✅ Your desired final layout
    slice: [ sliceObj ],
    smData: [ smDataObj ]
  };

  db.subscribers.updateOne({ imsi: imsi }, { $set: doc }, { upsert: true });
}

upsertSubscriber("001010123456780", 1, "internet1", 50, 9, 8);
upsertSubscriber("001010123456781", 2, "internet2", 10, 7, 2);
upsertSubscriber("001010123456783", 3, "internet3",  2, 9, 15);
MONGO_EOF

echo "[core] Starting Open5GS (your exact order + sleeps)..."

sleep 5
"$BIN_DIR/open5gs-nrfd" -c "$CFG_DIR/nrf.yaml" &

sleep 3
"$BIN_DIR/open5gs-udrd"  -c "$CFG_DIR/udr.yaml"  &
"$BIN_DIR/open5gs-pcfd"  -c "$CFG_DIR/pcf.yaml"  &
"$BIN_DIR/open5gs-ausfd" -c "$CFG_DIR/ausf.yaml" &
"$BIN_DIR/open5gs-udmd"  -c "$CFG_DIR/udm.yaml"  &
"$BIN_DIR/open5gs-nssfd" -c "$CFG_DIR/nssf.yaml" &

sleep 2
"$BIN_DIR/open5gs-smfd" -c "$CFG_DIR/smf.yaml" &
"$BIN_DIR/open5gs-upfd" -c "$CFG_DIR/upf.yaml" &

sleep 2
"$BIN_DIR/open5gs-amfd" -c "$CFG_DIR/amf.yaml" &

echo "[core] Core started. Running in background."
sleep infinity
