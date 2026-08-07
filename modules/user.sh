#!/usr/bin/env bash

collect_current_logged() {
	local max_records="${MAX_LOGIN_RECORDS:-50}"

	printf '=%.0s' {1..70}
	echo 
	echo "Collect currently loged "
	printf '=%.0s' {1..70}
	echo 
	
	if ! [[ "$max_records" =~ ^[0-9]+$ ]] ||
		(( 10#$max_records < 1))
	then
		echo "Error: MAZ_LOGIN_RECORDS must be a positive number" >&2
		return 1
	fi

	max_records=$((10#$max_records))

	echo 
	echo "--- CURRENTLY LOGGED-IN USERS ---"

	if command_exists who; then 
		if ! who -a; then
			echo "Erro: failed to collect current sessions" >&2
			return 1
		fi
	else
		echo "Error: who command is not available" >&2
		return 1
	fi

	echo "--- RECENT LOGIN RECORDS ---"
	echo "Maximum records: $max_records"

	if command_exists last; then
		if ! last -n "$max_records"; then
			echo "Error: failed to collect login history" >&2
			return 1
		fi 
	else
		echo "Error: last command is not available" >&2
		return 1
	fi 

	return 0
}
