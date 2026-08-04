#!/usr/bin/env bash

collect_modified_files() {
	local scan_path
	local failed_paths=0

	if (( ${#VALID_SCAN_PATHS[@]} == 0 )); then
		echo "Error: no validate scan paths are available" >&2
		return 1
	fi

	echo "Recently modified files"
	echo "Time range:previous $MODIFIED_DAYS day(s)"

	for scan_path in "${VALID_SCAN_PATHS[@]}"; do
		echo
		echo "Scan path: $scan_path"

		if ! find "$scan_path" \
			-xdev \
			-type f \
			-mtime "-$MODIFIED_DAYS" \
			-printf '%T+\t%m\t%u\t%g\t%s\t%p\n'
		then 
			echo "Error: find failed for : $scan_path" >&2
			failed_paths=$((failed_paths + 1 ))
		fi
	done 

	if (( failed_paths > 0 )) ;then
		return 1
	fi

	return 0
}
