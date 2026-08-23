#!/bin/bash

# tries to find playbooks
# The fourth parameter, when provided, is the product name.
find_glob=
if [[ $1 =~ ansible-playbook ]]; then
	find_glob="${3}-playbook-*.yml"
elif [[ $1 =~ ansible-lint ]]; then
	find_glob="${4:-}*.yml"
elif [[ $1 =~ yamllint ]]; then
	find_glob="${4:-}*.yml"
else
	echo "Error: '$1' is not expected executable" 1>&2
	exit 1
fi

cd "$2" || exit 1

readarray -t playbooks < <(find . -type f -name "${find_glob}")

# Scripts main purpose
# If no playbooks exist at all, then test is okay.
if (( ${#playbooks[@]} == 0 )); then
	echo "$2 does not contain any valid YAML files. Skipping the test."
	exit 0
fi

if [[ $1 =~ ansible-playbook ]]; then
	"$1" --syntax-check "${3}"-playbook-*.yml
	ret=$?
elif [[ $1 =~ ansible-lint ]]; then
	"$1" -c "$3" -p "${playbooks[@]}"
	ret=$?
elif [[ $1 =~ yamllint ]]; then
	"$1" -c "$3" "${playbooks[@]}"
	ret=$?
fi

exit $ret
