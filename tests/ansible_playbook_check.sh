#!/bin/bash

pushd "$2" > /dev/null

DIRS="" # directories which might contain playbooks
for dir in `find . -type d`
do
	# tries to find which directories contain valid playbooks
	FILES=$(ls $dir/*.yml 2> /dev/null | wc -l)
	if [ ! "$FILES" -eq "0" ]; then
		CONTAINS_VALID_FILES=1
		DIRS="$DIRS $dir/*.yml"
	fi
done

if [ -z "$CONTAINS_VALID_FILES" ]; then
	echo "$2 does not contain any valid YAML files. Skipping the test."
	popd > /dev/null
	exit 0
fi

if [[ $1 =~ ansible-playbook ]]; then
	$1 --syntax-check $3-playbook-*.yml
	ret=$?
elif [[ $1 =~ ansible-lint ]]; then
	$1 -c $3 -p $DIRS
	ret=$?
elif [[ $1 =~ yamllint ]]; then
	$1 -c $3 $DIRS
	ret=$?
else
	echo "Error: '$1' is not expected executable" 1>&2
	ret=1
fi

popd > /dev/null
exit $ret
