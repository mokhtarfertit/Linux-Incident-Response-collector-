#!/usr/bin/env bash

collect_command_history() {

	printf '=%.0s' {1..70}
	echo 
	echo "Collect Command history"
	printf '=%.0s' {1..70}
	echo 

	history

}
