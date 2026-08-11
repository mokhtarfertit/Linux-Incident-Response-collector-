#!/usr/bin/env bash

collect_system_logs() {
	local sources_collected=0
	local collection_failed=0
	local auth_file
	local system_file
	local auth_file_found=0
	local system_file_found=0
	local log_days
	local max_log_lines

	local auth_files=(
		"/var/log/auth.log"
		"/var/log/secure"
		)
	local system_files=(
		"/var/log/syslog"
		"/var/log/messages"
		)
	# validate LOG_DAYS
	if [[ ! "$LOG_DAYS" =~ ^[0-9]+$ ]]; then
		echo " LOG_DAYS must be a positive integer" >&2
		return 1
	fi

	if (( 10#$LOG_DAYS < 1 || 10#$LOG_DAYS > 365 )); then
		echo "Error: LOG_DAYS must be between 1 and 365" >&2
		return 1
	fi 

	# validate MAX_LOG_LINES
	if [[ ! "$MAX_LOG_LINES" =~ ^[0-9]+$ ]]; then
		echo "Error: MAX_LOG_LINES must be a postive integer" >&2
		return 1
	fi

	if (( 10#$MAX_LOG_LINES < 1 )); then 
		echo "Error: MAX_LOG_LINES must be greater than zero" >&2
		return 1
	fi

	log_days=$((10#$LOG_DAYS))
	max_log_lines=$((10#$MAX_LOG_LINES))

	printf '=%.os' {1..70}
	echo
	echo "COLLECT SYSTEM LOGS"
	printf '=%.0s'{1..70}
	echo

	echo "Time range: previous $logs_days day(s)"
	echo "Maximum lines per source: $max_log_lines"

	echo 
	echo "--- SYSTEM JOURNAL ---"

	if command_exists jounalctl; then
		if LC_ALL=C journalctl \
			--since "$log_days days ago" \
			--utc \
			--no-pager \
			--output=short-iso-precise \
			-n "$max_log_lines"
		then 
			sources_collected=$((sources_collected + 1))
		else
			echo "Error: failed to collect the system journal" >&2
			collection_failed=1
		fi
	else
		echo "journalctl is not available."
	fi

	echo 
	echo "--- AUTHENTICATION JOURNAL ---"

	if command_exists journalctl; then
		if LC_ALL=C journalctl \
			--since "$log_days days ago" \
			--utc \
			--no-pager \
			--output=short-iso-precise \
			-n "$max_log_lines" \
			SYSLOG_FACILITY=4 \
			SYSLOG_FACILITY=10
		then 
			source_collected=$((sources_collected + 1 ))
		else
			echo "Warning: failed to collect authenticationjournal entries" >&2
			collection_failed=1
		fi
	else
		echo "Authentication journal could not be collected ."
	fi

	echo 
	echo "--- TRADITIONAL AUTHENTICATION LOGS ---"

	if command_exists tail; then
		for auth_file in "${auth_files[@]}" do
			[[ -f "$auth_file" ]] || continue

			auth_file_found=1

			echo 
			echo "Log file: $auth_file"

			if [[ ! -r "$auth_file" ]]; then
				echo "Warning: authentication log is not readable: $auth_file" >&2
				collection_failed=1
				continue
			fi

			if tail -n "$max_log_lines" -- "$auth_file"; then
				sources_collected=$((sources_collected + 1))
			else
				echo "Error: failed to rad authentication log: $auth_file" >&2
				collection_failed=1 
			fi
		done
	else
		echo "Error: tail command is not available" >&2
		collection_failed=1
	fi

	if (( auth_file_found == 0 ));then
		echo "No traditional authentication log files were found."
	fi

	echo 
	echo "--- TRADITIONAL SYSTEM LOGS ---"

	if command_exists tail; then
		for system_file in "${system_files[@]}"; do
			[[ -f "$system_file" ]] || continue

			system_file_found=1

			echo 
			echo "Log file: $system_file"

			if [[ ! -r "$system_file" ]]; then
				echo "Warning: system log is not readale: $system_file" >&2
				collection_failed=1 
				continue
			fi

			if tail -n "$max_log_lines" -- "$system_file"; then
				sources_collected=$((sources_collected + 1))
			else
				echo "Error: failed to read system Log: $system_file" >&2
				collection_failed=1
			fi
		done
	else
		echo "Error: tail command is not available" >&2
		collection_failed=1
	fi

	if (( system_file_found == 0 )); then
		echo "No traditional system log files were found."
	fi

	echo 
	echo "--- KERNEL LOGS ---"

	if command_exists journalctl; then
		if LC_ALL=C journalctl \
			--kernel \
			--since "
	





}
