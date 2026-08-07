#!/usr/bin/env bash

collect_system_info() {
	printf '=%.0s' {1..70}
	echo 
	echo "Collect System Info"
	printf '=%.0s' {1..70}
	echo 

	echo 
	echo "--- HOSTNAME ---"
	if ! hostname; then 
		echo "Error: failed to collect hostname" >&2
		return 1
	fi

	echo 
	echo "--- KERNEL INFORMATION ---"
	if ! uname -a; then 
		echo "Error: failed to collect kernel information" >&2
		return 1
	fi

	echo 
	echo "--- OPERATING SYSTEM ---"
	if [[ -r /etc/os-release ]]; then
		cat /etc/os-release
	else
		echo "/etc/os-release is not available"
	fi

	echo 
	echo "-- CURRENT UTC TIME ---"
	date -u "+%Y-%m-%d %H:%M:%SZ"

	echo 
	echo "--- SYSTEM UPTIME ---"
	uptime 

	echo 
	echo "--- HOSTNAEMCTL INFORMATION ---"
	if command_exists hostnamectl; then
		if ! hostnamectl;then
			echo "hostname exists but could not collect information"
		fi
	else
		echo "hostnamectil is not available"
	fi

	echo "--- CPU INFORMATION ---"
	if command_exists lscpu; then
		lscpu
	else
		echo "lscpu is not availalble"
	fi

	echo 
	echo "--- MEMORY INFORAMTION ---"
	if command_exists free; then
		free -h
	else
		echo "free is not available"
	fi

	echo 
	echo "--- BLOCK DEVICES ---"
	if command_exists lsblk; then
		lsblk -f
	else
		echo "lsblk is not available"
	fi

	return 0


}
