#!/usr/bin/env bash

collect_listening_ports() {

	printf '=%.0s' {1..70}
	echo 
	echo "collect listening ports"
	printf '=%.0s' {1..70}
	echo 
	
	echo 
	echo "--- LISTENING TCP AND UDP PORTS ---"
	
	if command_exists ss; then
		if ! ss -lntup; then
			echo "Error: ss failed to collect listening ports" >&2
			return 1
		fi
	elif command_exists netstat; then
		echo "ss is unavailable; using netstat insted."

		if ! netstat -lntup; then
			echo "Error: netstat failed to collect listening ports" >&2
			return 1
		fi
	else
		echo "Error: neither ss nor netstat is available" >&2
		return 1
	fi

	return 0
}

