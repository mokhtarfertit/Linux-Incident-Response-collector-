#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="$BASE_DIR/config/config.collector.conf"
HELPER_PATH="$BASE_DIR/utils/helpers.sh"
MODULE_PATH="$BASE_DIR/modules"
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

#load all modules for can use it
module_count=0

for module_file in "$MODULE_PATH"/*.sh; do
	# when no .sh file exist, bash leaves the pattern unchanged.
	[[ -e "$module_file" ]] || continue

	if [[ ! -f "$module_file" ]]; then
		echo "Error: module is not a regular file: $module_file" >&2
		exit 1
	fi

	if [[ ! -r "$module_file" ]]; then
		echo "Error: module is not readable: $module_file" >&2
		exit 1
	fi

	if ! source "$module_file"; then
		echo "Error: failed to load mddule: $module_file" >&2
		exit 1
	fi

	((module_count++))
done

if (( module_count == 0 )); then
	echo "Error: no module files found in :$MODULE_PATH" >&2
	exit 1
fi

# validate and prepare the report directory
if [[ -e "$REPORT_DIR" && ! -d "$REPORT_DIR" ]]; then
	echo "Error: report path exists but is not a directory: $REPORT_DIR" >&2
	exit 1
fi

if [[ ! -d "$REPORT_DIR" ]]; then
	log_message "INFO" "creating report diretory: $REPORT_DIR"

	if ! create_directory "$REPORT_DIR"; then
		echo "Error: could not create report directory: $REPORT_DIR" >&2
		exit 1
	fi
fi

if ! is_readable "$REPORT_DIR"; then
	echo "Error: report directory is not readable : $REPORT_DIR" >&2
	exit 1
fi 

if ! is_writable "$REPORT_DIR"; then 
	echo "Error: report directory is not writable: $REPORT_DIR" >&2
	exit 1
fi

log_message "SUCCESS" "Report direcotory is ready: $REPORT_DIR"

#run all mdoules
run_all_modules() {
	local failed_modules=0
	
	run_module collect_current_logged ||
		failed_modules=$((failed_modules + 1))
	
	run_module collect_running_processes ||
		failed_modules=$((failed_modules + 1))

	run_module collect_scheduled_jobs ||
		failed_modules=$((failed_modules + 1))

	run_module collect_system_info ||
		failed_modules=$((failed_modules + 1))

	run_module collect_network_connection ||
		failed_modules=$((failed_modules + 1))

	run_module collect_command_history ||
		failed_modules=$((failed_modules + 1))

	run_module collect_listening_ports ||
		failed_modules=$((failed_modules + 1))

	run_module collect_modified_files ||
		failed_modules=$((failed_modules + 1))

	if (( failed_modules > 0 ));then 
		log_message "ERROR" "$failed_modules module(s) failed"
		return 1
	fi 

	log_message "SUCCESS" "All module completed successfully"
	return 0
}	

#run selected modules 
run_selected_modules() {
	local index
	local function_name
	local failed_modules=0
	if (( ${#SELECTED_MODULE_INDICES[@]} == 0 )); then 
		log_message "ERROR" "No modules were selected"
		return 1
	fi

	for index in "${SELECTED_MODULE_INDICES[@]}"; do
		function_name="${MODULE_FUNCTIONS[$index]}"

		if ! run_module "$function_name"; then
			failed_modules=$((failed_modules + 1))
		fi
	done

	if (( failed_modules > 0 )); then 
		log_message "ERROR" "$failed_modules selected modules(s) failed"
		return 1
	fi

	log_message "SUCCESS" \
		"All selected modules completed successufully"
	return 0
}
			

#Start the script 
write_report_header "Linux Incident Response Collector"

#check priviles run as a root
if is_root ; then
	echo "Ruunning with root privileges."
else
	echo "Warning: script is not runningg with sudo."
fi

##### check modified days
if [[ ! "$MODIFIED_DAYS" =~ ^[0-9]+$ ]]; then 
	echo "Invalid value: modified days must be a number"
	echo "change in file of conig"
	exit 1
elif (( "$MODIFIED_DAYS" > 365 || "$MODIFIED_DAYS" < 1  )); then 
	echo "invalide number should be less than 365 and big than 0 : $MODIFIED_DAYS"
	echo "change in file of config"
	exit 1
else 
	echo "modified days valid...."
fi

##### check configured scan paths exist
validate_scan_paths() {
	local scan_path
	
	VALID_SCAN_PATHS=()

	if [[ "$(declare -p SCAN_PATH 2>/dev/null)" != "declare -a"* ]]; then
		echo "Error: SCAN_PATH must be a Bash array" >&2
		return 1
	fi

	if (( ${#SCAN_PATH[@]} == 0 )); then
		echo "Error: SCAN_PATH cannot be empty" >&2
		return 1
	fi

	for scan_path in "${SCAN_PATH[@]}";do
		if [[ -z "$scan_path" ]]; then
			log_message "WARRING" "Igonring an empty scan path"
			continue
		fi

		if [[ ! -e "$scan_path" ]]; then
			log_message "WARRING" "Scan path does not exist: $scan_path"
			continue
		fi

		if [[ ! -d "$scan_path" ]]; then
			log_message "WARRING" "Scan path is not a directory: $scan_path"
			continue
		fi

		if [[ ! -r "$scan_path" ]]; then
			log_message "WARRING" "Scan path is not a readable: $scan_path"
			continue
		fi

		VALID_SCAN_PATHS+=("$scan_path")
		log_message "SUCCESS" "Valid scan path: $scan_path"
	done

	if (( ${#VALID_SCAN_PATHS[@]} == 0 )); then 
		echo "Error: no valid scan paths are available" >&2
		return 1
	fi
	
	return 0
}	

# Display the main menu

collect_all_evidence() {
	#Collect all evidence: not implemented yet.
	enable_all_modules
	display_selected_modules

	if ! prepare_report_directory; then
		return 1
	fi 

	run_all_modules
}

select_specific_modules() {
	local choices
	local choice
	local index
	local module_count
	local function_name

	SELECTED_MODULE_INDICES=()

	display_available_modules

	echo "Enter one or more modul numbers separated by spaces:"
	read -r -a choices

	module_count="${#MODULE_LABELS[@]}"
	for choice in "${choices[@]}"; do
		if [[ "$choice" =~ ^[0-9]+$ ]] &&	
		(( 10#$choice >=1 && 10#$choice <=module_count )); then
			index=$((10#$choice - 1))
			function_name="${MODULE_FUNCTIONS[$index]}"

			if is_module_selected "$function_name"; then
				echo "Already selected: ${MODULE_LABELS[$index]}"
				continue 
			fi 

			SELECTED_MODULE_INDICES+=("$index")
		else
			echo "Invalid choice: $choice"
		fi
	done 



	# ask for the time range 
	local days="$MODIFIED_DAYS"

	if (( ${#SELECTED_MODULE_INDICES[@]} == 0 )); then
		echo "No valid modules were selected."
		return 1	
	fi
	if is_module_selected "collect_modified_files"; then
		if ! days="$(prompt_for_days)"; then
			return 1
		fi
	fi
	# show collection summary 
	printf '=%.0s' {1..70}
        echo
        echo "COLLECTION SUMMARY"
        printf '=%.0s' {1..70}
        echo
	display_selected_modules
	if is_module_selected "collect_modified_files"; then 
		echo "Modified-file time range: $days day(s)"
	fi
        ###########check priviles run as a root
	if is_root ; then
        	echo "Ruunning with root privileges."
	else
        	echo "Warning: script is not runningg with sudo."
	fi
	while true; do
		
		if ! read -r -p  "Continue with collections?  (yes/no):" answer; then
			echo "Error: could not read your answer" >&2
			return 1
		fi
	
		case "${answer,,}" in
			yes|y)
				echo "continuing.."

				if is_module_selected "collect_modified_files"; then
					MODIFIED_DAYS="$days"
				fi

				if ! prepare_report_directory; then 
					return 1
				fi

				if ! run_selected_modules; then
					return 1
				fi

				return 0
				;;
			no|n)
				echo "Collection cancelled."
				return 0
				;;
			*)
				echo "Please enter yes or no"
				;;
			esac
done
}
#Create the report directory
INCIDENT_DIR=""
prepare_report_directory() {
	local timestamp
	
	if [[ -e "$REPORT_DIR" && ! -d "$REPORT_DIR" ]]; then 
		echo "Error: report path exists but is not a direcotry: $REPORT_DIR" >&2
		return 1
	fi 

	if ! mkdir -p -- "$REPORT_DIR"; then
		echo "Error: could not create report directory: $REPORT_DIR" >&2
		return 1
	fi 

	if [[ ! -w "$REPORT_DIR" ]]; then
		echo "Error: report directory is not writable : $REPORT_DIR" >&2
		echo "check its owner and permissions; do not use chmod 777." >&2
		return 1
	fi

	if ! chmod 700 -- "$REPORT_DIR"; then
		echo "Error: could not secure report directory: $REPORT_DIR" >&2
		return 1
	fi 
	
	timestamp=$(date -u "+%Y-%m-%d_%H-%M-%SZ")

	if ! INCIDENT_DIR=$(mktemp -d "$REPORT_DIR/incident_${timestamp}_XXXXXX"); then
		echo "Erro: could not create incident directory" >&2
		return 1
	fi
	
	if ! chmod 700 -- "$INCIDENT_DIR"; then 
		echo "Erro: could not secure incident directory: $INCIDENT_DIR" >&2
		return 1
	fi

	log_message "SUCCESS" "Incident diretory created: $INCIDENT_DIR"
	return 0
}	
#run statup validatoin

if ! validate_scan_paths; then
	exit 1
fi
# load module file
load_module_files() {
	#checki if all modules exist 
	echo "test1"
	#check the collected modules are exist 

}
while true; do
	display_main_menu
	read -r -p "Enter number from Menu: " choice
	case "$choice" in
		1)
			collect_all_evidence
			;;
		2)
			select_specific_modules
			;;
		3)
			echo "Exiting.."
			break
			;;
		*)
			echo "invalid choice."
			;;
	esac
done
