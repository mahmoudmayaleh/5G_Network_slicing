#!/usr/bin/env bash
set -euo pipefail


cd /opt/srsRAN_4G/build/srsue/src
exec ./srsue /etc/srsran/ue.conf
