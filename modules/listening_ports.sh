#!/usr/bin/env bash

collect_listening_ports() {

	printf '=%.0s' {1..70}
	echo 
	echo "collect_listening_ports"
	printf '=%.0s' {1..70}
	echo 

	ss -tulnp
}
