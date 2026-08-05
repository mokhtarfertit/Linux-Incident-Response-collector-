#!/usr/bin/env bash

collect_scheduled_jobs() {

	printf '=%.0s' {1..70}
	echo 
	echo "Collect sheduled jobs"
	printf '=%.0s' {1..70}
	echo 
	
	if ! command -v crontab >/dev/null 2>&1; then 
		echo "Error: crontab command is not available" >&2
		return 1
	fi

	local output

	if output="$(LC_ALL=C crontab -l 2>&1)"; then
		printf '%s\n' "$output"
		return 0
	fi

	if [[ "$output" == *"no crontab for"* ]]; then 
		echo "NO crontab is configured for user: $(id -un)"
		return 0
	fi 

	printf 'Error reading crontab : %s\n' "$output" >&2
	return 1
}
