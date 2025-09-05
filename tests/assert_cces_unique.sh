#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
# 1. Find all cces in all rule.yml files
# 2. Collect the CCE strings, don't care about CCE product-qualification, and remove quotes
# 3. Sort those numbers
readarray -t all_rule_files < <(find "$PROJECT_ROOT" -name rule.yml)
all_cces=$(grep '^\s*\<cce\(@\w*\)\?:' "${all_rule_files[@]}" | sed -e 's/.*cce.*:\s*//' | tr -d "'\"" | sort)
# 4. Get the differences

readarray -t duplicate_cces < <(uniq -d <<< "$all_cces")

function handle_duplicate {
	local dup="$1" occurrence
	# Find all files containing incriminated CCEs, and
	# shorten filenames, so they are relative to the project root.
	readarray -t occurrence < <(grep -l "cce.*:\\s*\\<${dup}" "${all_rule_files[@]}" | sed -e "s|^$PROJECT_ROOT/||")

	echo >&2
	printf 'CCE %s is included in files: \n' "$dup" >&2
	printf ' - %s\n' "${occurrence[@]}" >&2
	return 1
}

for dup in "${duplicate_cces[@]}"; do
	handle_duplicate "$dup"
done
