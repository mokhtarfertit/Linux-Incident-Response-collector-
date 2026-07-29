#!/usr/bin/env bash


collect_running_processes() {
	printf '=%.0s' {1..70}
	echo 
	echo "Collect Running Processes"
	printf '=%.0s' {1..70}
	echo
	ps
}


