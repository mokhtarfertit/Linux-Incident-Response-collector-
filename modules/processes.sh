#!/usr/bin/env bash


collect_running_processes() {
	printf '=%.0s' {1..70}
	echo 
	echo "Collect Running Processes"
	printf '=%.0s' {1..70}
	echo
	
	if ! command_exists ps; then
		echo "Error: ps command is not available" >&2
		return 1
	fi

	echo "Detailed process list:"
	echo 

	if ! ps -eo \
		pid,ppid,uid,user,gid,group,lstart,etime,stat,%cpu,%mem,args \
		--sort=pid
	then
		echo "Error: failed to collect running processes" >&2
		return 1
	fi

	return 0
}


