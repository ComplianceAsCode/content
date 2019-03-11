function include_merge_files_by_lines {
	:
}

# 1: Filename of the "master" file
# 2: Filename of the newly created file
function create_empty_file_like {
	local lines_count
	lines_count=$(cat "$1" | wc -l)
	for _ in $(seq 1 "$lines_count"); do
		printf '\n' >> "$2"
	done
}


# 1: Filename of the "master" file
# 2: Filename of sample flie
function second_file_is_same_except_newlines {
	local lines_of_master lines_of_sample len_of_master line_number i
	readarray -t lines_of_master < "$1"
	readarray -t lines_of_sample < "$2"

	len_of_master="${#lines_of_master[@]}"
	if test "$len_of_master" != "${#lines_of_sample[@]}"; then
		echo "Files '$1' and '$2' have different number of lines, $len_of_master and ${#lines_of_sample[@]} respectively."
		return 1
	fi

	for line_number in $(seq 1 "$len_of_master"); do
		i=$((line_number - 1))
		test -n "${lines_of_sample[$i]}" || continue
		if test "${lines_of_master[$i]}" != "${lines_of_sample[$i]}"; then
			echo "Line $line_number is different in files '$1' and '$2'."
			return 1
		fi
	done
}


# 1: Filename of the "master" file
# 2: Filename of sample flie
# 3: List of indices (1-based, space-separated string)
function merge_first_lines_to_second_on_indices {
	local lines_of_master lines_of_sample line_number i
	test -f "$2" || create_empty_file_like "$1" "$2"

	readarray -t lines_of_master < "$1"
	readarray -t lines_of_sample < "$2"

	error_msg="$(second_file_is_same_except_newlines "$1" "$2")"
	if test $? != 0; then
		echo "Error merging lines into '$2': $error_msg" >&2
		return 1
	fi

	for line_number in $3; do
		i=$((line_number - 1))
		lines_of_sample[$i]="${lines_of_master[$i]}"
	done

	printf "%s\n" "${lines_of_sample[@]}" > "$2"
}
