#!/usr/bin/env bash

collect_network_connection() {
	local collection_failed=0


	printf '=%.0s' {1..70}
	echo 
	echo "Collect Network Connection"
	printf '=%.0s' {1..70}
	echo 

	echo
	echo "--- NETWORK INTERFACES ---"

	if command_exists ip; then
		if ! ip address show; then
			echo "Error: failed to collect network interfaces" >&2
			collection_failed=1
		fi
	else
		echo "Error: is command is not available" >&2
		collection_failed=1 
	fi 
	
	echo 
	echo "--- IPV4 ROUTES ---"
	
	if command_exists ip; then
		if ! ip route show table all; then
			echo "Error: failed to collect IPV4 routes" >&2
			collection_failed=1
		fi
	else
		echo "IPV4 routes could not be collected"
	fi

	echo 
	echo "--- IPV6 ROUTES ---"

	if command_exists ip; then
		if ! ip -6 route show table all; then
			echo "Error: failed to collect IPv6 routes" >&2
			collection_failed=1
		fi
	else
		echo "IPV6 routes could not be collected."
	fi

	echo 
	echo "--- ACTIVE NETWORK CONNECTIONS ---"

	if command_exists netstat; then
		echo "ss is unavailable; using netstat instead."

		if ! netstat -tunap; then 
			echo "Error: netstat failed to collect connections" >&2
			collections_failed=1
		fi
	else
		echo "Error: neither ss nor netstat is available" >&2
		collection_failed=1
	fi 

	if (( collection_failed > 0 )); then
		return 1
	fi 

	return 0
}
