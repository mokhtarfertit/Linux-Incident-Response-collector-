#!/usr/bin/env bash

collect_scheduled_jobs() {

	printf '=%.0s' {1..70}
	echo 
	echo "Collect sheduled jobs"
	printf '=%.0s' {1..70}
	echo 
	crontab -l
}
