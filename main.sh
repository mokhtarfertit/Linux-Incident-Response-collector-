#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="$BASE_DIR/config/config.collector.conf"
HELPER_PATH="$BASE_DIR/utils/helpers.sh"
REPORT_DIR="$BASE_DIR/reports"

#check requret of project
if [[ ! -f "$CONFIG_PATH" || ! -f "$HELPER_PATH" ]]; then
	echo "A required file is missing"
	exit 1
fi


#Load the configuration file
source "$CONFIG_PATH"
#Load the helper functions 
source "$HELPER_PATH"

#Start the script 
write_report_header "Linux Incident Response Collector"

#check priviles run as a root
if is_root ; then
	echo "Ruunning with root privileges."
else
	echo "Warning: script is not runningg with sudo."
fi

#valideate configuration 

if [[ ! -d "$REPORT_DIR" ]]; then
	echo "the folder report not exit "
	create_directory "$REPROT_DIR"
elif [[ ! -n "$REPORT_DIR" ]]; then 
	echo "folder reports is empty"
elif ! (is_writable "$REPORT_DIR"); then 
	echo "the folder not writable"
elif ! (is_readable "$REPORT_DIR"); then
	echo "the folder nit redadable"
else
	continue
fi


