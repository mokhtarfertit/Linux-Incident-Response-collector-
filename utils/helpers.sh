#!/usr/bin/env bash

# displays normal progress messages
log_message() {
	local level="$1"
	local message="$2"
	local timestamp

	timestamp=$(date "+%Y-%m-%d %H:%M:%S")

	echo "[$timestamp] [$level] $message"
}

# check whether a linux command such as ss.... is installed or not 

command_exists() {
	local command_name="$1"

	command -v "$command_name" >/dev/null 2>&1
}

#checks whether the script is running with root privileges
is_root() {
	[[ "$EUID" -eq 0 ]]
}

#adds a clear title , hostnem , date ,and collection time to report files.
write_report_header() {
	local title="$1"
	local system_hostname
	local timestamp 
	
	system_hostname=$(hostname)
	timestamp=$(date "+%Y-%m-%d %H:%M:%S")
	
	printf '=%.0s' {1..70} 
	echo
	echo "$title"
	echo "Hostname is: $system_hostname"
	echo "Collection time : $timestamp"
	printf '=%.0s' {1..70} 
	echo
}

# create ad directory and verifies that creation succeeded
create_directory() {
	local folder_path="$1"
	
	mkdir -p  "$folder_path" || return 1
	[[ -d "$folder_path" ]]
}

#ckecks whether a file or directory can be read.
is_readable() {
	local path="$1"

	[[ -r "$path" ]]
}

#checks whether a destination direcotyr can be written to
is_writable() {
	local path="$1"

	[[ -w "$path" ]]
}

# runs a collection function and records whether is succeded or failed
run_module() {
	local module_name="$1"

	log_message "INFO" "Running module: $module_name"

	if "$module_name";then
		log_message "SUCCESS" "Module succeeded: $module_name"
		return 0 
	else
		log_message "ERROR" "module failed: $module_name"
		return 1
	fi
}
display_main_menu() {
	echo "1. collect all evidence"
	echo "2. Select specific evidence modules"
	echo "3. Exist"
}

AVAILABLE_MODULES=(
		"PROCESSES"
		"USERS"
		"NETWORK"
		"SCHEDULED_JOBS"
		"LISTENING PORTS"
		"COMMAND HISTORY"
		"SYSTEM INFO"
		"MODIFIED FILES"
	)
display_available_modules() {
	local index
	printf '=%.0s' {1..70}
	echo
	echo "AVAILABLE MODULES"
	printf '=%.0s' {1..70}
	echo
	
	for index in "${!AVAILABLE_MODULES[@]}"; do
		echo "$((index + 1)). ${AVAILABLE_MODULES[$index]}"
	done
	printf '=%.0s' {1..70}
	echo 

}














