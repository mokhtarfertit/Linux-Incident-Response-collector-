#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="$BASE_DIR/config/collector.conf"
HELPER_PATH="$BASE_DIR/utils/helpers.sh"

#Start the script 
source $HELPER_PATH
write_report_header "Linux Incident Response Collector"

