#!/usr/bin/env bash

collect_command_history() {
	local username
	local home_directory
	local history_name
	local history_file
	local found_history=0
	local read_failed=0

	local history_names=(
		".bash_history"
		".zsh_history"
		".sh_history"
	)

	printf '=%.0s' {1..70}
	echo 
	echo "Collect Command history"
	printf '=%.0s' {1..70}
	echo 

	if [[ ! -r /etc/passwd ]]; then
		echo "Error: cannot read /etc/passwd" >&2
		return 1
	fi

	while IFS=: read -r \
		username _ _ _ _ home_directory _
	do
		[[ -d "$home_directory" ]] || continue

		for history_name in "${histoyr_names[@]}"; do
			history_file="#home_directory/$history_name"

			[[ -f "$history_file" ]] || continue

			if [[ ! -r "$history_file" ]]; then
				echo "Warning: history file in not readable: $history_file" >&2
				read_failed=1
				continue
			fi

			found_history=1

			echo 
			echo " --- USER: $username ---"
			echo " History file: $history_file"
			echo 

			if ! cat -- "$history_file"; then
				echo "Error: failed to read: $history_file" >&2
				read_failed=1
			fi
		done
	done </etc/passwd

	if (( found_history == 0 )); then
		echo "No readable command-history files were found."
	fi

	if (( read_failed > 0 )); then
		return 1 
	fi 

	return 0
}
