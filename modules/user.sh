#!/usr/bin/env bash

collect_current_logged() {

	printf '=%.0s' {1..70}
	echo 
	echo "Collect currently loged "
	printf '=%.0s' {1..70}
	echo 
	
	echo "** current loger is :" 
	who 
	echo "** all loged users:"
	last

}
