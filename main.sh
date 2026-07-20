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
	echo "valid...."
fi

##### check modified days
if [[ "$MODIFIED_DAYS" =~ ^[0-9]+$ ]]; then 
	echo "valid...."
elif [[ "$MODIFIED_DAYS" > 365 || "$MODIFIED_DAYS" < 0  ]]; then 
	echo "invalide number should be less than 365 and big than 0"
	echo "change in file of config"
	exit 1
else 
	echo "Invalid value: modified days must be a number"
	echo "change in file of conig"
	exit 1
fi

##### check configured scan paths exist
if [[ ! -e "$SCAN_PATH" ]]; then 
	echo "the path scan is not exit "
	exit 1
elif [[ ! -d "$SCAN_PATH" ]]; then
	echo "same part in path not directory "
	exit 1
elif ! is_readable "$SCAN_PATH"; then 
	echo " the folder not readabel "
	exit 1
else
	echo "valid...."
fi

