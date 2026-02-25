#!/usr/bin/env bash
set -euo pipefail

# Change this path if your script is elsewhere in the container
cd /app
exec python3 multi_ue_scenario.py
