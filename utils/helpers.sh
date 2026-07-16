#!/usr/bin/env bash

# displays normal progress messages
log_indo() {
	local level="$1"
	local message="$2"
	local timestamp

	timestamp=$(date "+%Y-%m-%d %H:%M:%S")

	echo "[$timestamp] [$level] $message"
}

# check whether a linux command such as ss.... is installed or not 

command_exists() {
	loacl command_name="$1"

	command -v "$command_name" >/dev/null 2>&1
}

#checks whether the script is running with root privileges
is_root() {
	[[ "$EUID -eq 0 "]]
}

#adds a clear title , hostnem , date ,and collection time to report files.
write_reporte_header() {
	local title="$1"
	local hostname="$2"
	local timestamp 
	
	timestamp=$(date "+%Y-%m-%d %H:%M:%S")
	
	printf '=%.0' {1..70} echo
	echo "$title"
	echo "hostname is: $hostname"
	echo "$timestamp"
	printf '=%.0' {1..70} echo
}

