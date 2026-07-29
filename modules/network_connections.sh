#!/usr/bin/env bash

collect_network_connection() {

	printf '=%.0s' {1..70}
	echo 
	echo "Collect Network Connection"
	printf '=%.0s' {1..70}
	echo 

	ss -tunap

}
