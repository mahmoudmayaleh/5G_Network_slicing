#!/usr/bin/env bash
set -euo pipefail

cd /opt/srsRAN_Project/build/apps/gnb
exec ./gnb -c /etc/srsran/gnb.yaml
