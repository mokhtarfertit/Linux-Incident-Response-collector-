#!/usr/bin/env bash

UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$UTILS_DIR/.." && pwd)"
CONFIG_PATH="$BASE_DIR/config/config.collector.conf"

#Load the configuration file
source "$CONFIG_PATH"

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
	local evidence_name
	local output_file
	local error_file
	local exit_code

	if [[ -z "$INCIDENT_DIR" || ! -d "$INCIDENT_DIR" ]]; then 
		log_message "ERROR" "Incident directory is not ready"
		return 1
	fi

	if ! declare -F "$module_name" >/dev/null; then
		log_message "ERROR" "Module funtion not exist: $module_name"
		return 1
	fi

	evidence_name="${module_name#collect_}"
	output_file="$INCIDENT_DIR/${evidence_name}.txt"
	error_file="$INCIDENT_DIR/${evidence_name}.stderr.txt"

	log_message "INFO" "Running module: $module_name"

	{
		write_report_header "$module_name"
		"$module_name"
	} >"$output_file" 2>"$error_file"

	exit_code=$?

	if (( exit_code == 0 )); then
		log_message "SUCCESS" "Module succeeded: $module_name"
	else
		log_message "ERROR" \
			"Module failed: $module_name (exit code: $exit_code)"
	fi

	return "$exit_code"
}
display_main_menu() {
	echo "1. collect all evidence"
	echo "2. Select specific evidence modules"
	echo "3. Exist"
}
MODULE_CONFIG_FLAGS=(
	"COLLECT_PROCESSES"
	"COLLECT_USERS"
	"COLLECT_NETWORK_CONNECTIONS"
	"COLLECT_SCHEDULED_JOBS"
	"COLLECT_LISTENING_PORTS"
	"COLLECT_COMMAND_HISTORY"
	"COLLECT_SYSTEM_INFO"
	"COLLECT_MODIFIED_FILES"
)

MODULE_LABELS=(
	"Runnig porcesses"
	"Logged-in users"
	"Network connections"
	"Scheduled jobs"
	"Listening ports"
	"Command history"
	"System information"
	"Modified files"
)

MODULE_FUNCTIONS=(
	"collect_running_processes"
	"collect_current_logged"
	"collect_network_connection"
	"collect_scheduled_jobs"
	"collect_listening_ports"
	"collect_command_history"
	"collect_system_info"
	"collect_modified_files"
)
SELECTED_MODULE_INDICES=()
	

enable_all_modules() {
	SELECTED_MODULE_INDICES=("${!MODULE_LABELS[@]}")
	printf '=%.0s' {1..70}
	echo
	echo "COLLECT ALL MODULES"
	printf '=%.0s' {1..70}
	echo

	display_selected_modules
}

display_available_modules() {
	#this fontion for display all fontion with give it index
	local index
	printf '=%.0s' {1..70}
	echo
	echo "AVAILABLE MODULES"
	printf '=%.0s' {1..70}
	echo
	
	for index in "${!MODULE_LABELS[@]}"; do
		echo "$((index + 1)). ${MODULE_LABELS[$index]}"
	done
	printf '=%.0s' {1..70}
	echo 

}
display_selected_modules() {
	#display selected modules this fontion use with specific modole
	local index
	
	echo "Selected modules:"

	for index in "${SELECTED_MODULE_INDICES[@]}"; do
		echo "- ${MODULE_LABELS[$index]}"
	done
}
prompt_for_days() {
	local days

	while true; do
		printf "Enter number of days [%s]: " "$MODIFIED_DAYS" >&2

		if ! read -r days; then 
			echo "Error: could not read the number of days" >&2
			return 1
		fi

		days="${days:-$MODIFIED_DAYS}"

		if [[ "$days" =~ ^[0-9]+$ ]] && 
			(( 10#$days >=1 && 10#$days <= 365 ))
		then 
			printf '%s\n' "$days"
			return 0
		fi 
		
		echo "Please enter a whole number between 1 and 365." >&2
	done

}

#check whethe a function was selected
is_module_selected() {
	local target_function="$1"
	local index

	for index in "${SELECTED_MODULE_INDICES[@]}"; do
		if [[ "${MODULE_FUNCTIONS[$index]}" == "$target_function" ]]; then
			return 0
		fi
	done
	
	return 1 
}
#check if module is enable in configration or not
module_is_enabled() {
	local index="$1"
	local config_name
	local config_value

	config_name="${MODULE_CONFIG_FLAGS[$index]}"

	if [[ ! -v "$config_name" ]]; then
		log_message "ERROR" \ 
			"Missing configuration option: $config_name"
		return 1
	fi 
	
	config_value="${!config_name}"

	[[ "$config_value,,}" == "true" ]]
}
	









