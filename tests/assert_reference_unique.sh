#!/bin/bash

REF=$1

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
# 1. Find all references pointed by REF in all rule.yml files
# 2. Collect the REF strings, don't care about product-qualification, and remove quotes and trailing whitespaces
# 3. Sort references
readarray -t all_rule_files < <(find "$PROJECT_ROOT" -name rule.yml)
all_matches=$(grep "^\s*\<${REF}\(@\w*\)\?:" "${all_rule_files[@]}" | sed -e "s/.*${REF}.*:\s*//" | tr -d "'\"" | sed 's/[[:space:]]*$//' | sort)
# 4. Get the differences

readarray -t duplicated_list < <(uniq -d <<< "$all_matches")

function handle_duplicate {
	local dup="$1" occurrence
	# Find all files containing duplicated references, and
	# shorten filenames, so they are relative to the project root.
	readarray -t occurrence < <(grep -l "${REF}.*:\\s*\\<${dup}" "${all_rule_files[@]}" | sed -e "s|^$PROJECT_ROOT/||")

	echo >&2
	printf '%s %s is included in files: \n' "${REF}" "${dup}" >&2
	printf ' - %s\n' "${occurrence[@]}" >&2
	return 1
}

for dup in "${duplicated_list[@]}"; do
	handle_duplicate "$dup"
done
