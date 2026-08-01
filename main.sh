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
for module_file in "$MODULE_PATH"/*.sh; do
	source "$module_file"
done

#run all mdoules
run_all_modules() {
	collect_current_logged
	collect_running_processes
	collect_scheduled_jobs
	collect_system_info
	collect_network_connection
	collect_command_history
	collect_listening_ports
	collect_modified_files
}	


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
	create_directory "$REPORT_DIR"
elif [[ ! -n "$REPORT_DIR" ]]; then 
	echo "folder reports is empty"
elif ! (is_writable "$REPORT_DIR"); then 
	echo "the folder not writable"
elif ! (is_readable "$REPORT_DIR"); then
	echo "the folder nit redadable"
else
	echo "configuraton valid...."
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
	echo "scan path valid...."
fi


# Display the main menu

collect_all_evidence() {
	#Collect all evidence: not implemented yet.
	enable_all_modules
}

select_specific_modules() {
	local choices
	local choice
	local index
	local module_count

	SELECTED_MODULES=()

	display_available_modules

	echo "Enter one or more modul numbers separated by spaces:"
	read -r -a choices

	module_count="${#AVAILABLE_MODULES[@]}"

	# Read one or more choices
	# validate each choice
	# Add valid modules names to SELECTED_MODULES
	for choice in "${choices[@]}"; do
		# validate that choice is a number
		# convert user number to bash array index
		# store the selcted module name
		if [[ "$choice" =~ ^[0-9]+$ ]] &&	
		(( choice >=1 && choice <=module_count )); then
			index=$((choice - 1))
			SELECTED_MODULES+=("${AVAILABLE_MODULES[$index]}")
		else
			echo "Invalid choice: $choice"
		fi
	done 



	# ask for the time range 
	local days
	if [[ ${#SELECTED_MODULES[@]} -gt 0 ]]; then
		echo "The array is not empty"
		Check_Number_Days days	
	else
		echo "the array is emty"
		exit 1
	fi
	# show collection summary 
	printf '=%.0s' {1..70}
        echo
        echo "COLLECTION SUMMARY"
        printf '=%.0s' {1..70}
        echo
	display_selected_modules
	echo "the modified file time range is : $days"
        ###########check priviles run as a root
	if is_root ; then
        	echo "Ruunning with root privileges."
	else
        	echo "Warning: script is not runningg with sudo."
	fi
	read -r -p  "the information like you want (yes/no):" answer
	
	if [[ "$answer" == "yes" ]]; then
		echo "continuing.."
	elif [[ "$answer" == "no" ]]; then
		echo "Stopping.."
		exit 1
	else 
		echo "Please enter yes or no."
	fi
	printf '=%.0s' {1..70}
        echo
}
#Create the report directory
prepare_report_direcotory() {
	local timestamp
        local folder_name	

	timestamp=$(date "+%Y-%m-%d_%H-%M-%S")

	folder_name="incident_$timestamp"
	
	incident_folder="$REPORT_DIR/$folder_name"
	create_directory "$incident_folder"
	
	#verfiy that the directory exists and is writable 
	if [[ -d "$incident_folder" && -w "$incident_folder" ]]; then
		echo "Folder exists and is writable "
	else
		echo "folder is missing or not writable"
		exit 1 
	fi


}	
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
