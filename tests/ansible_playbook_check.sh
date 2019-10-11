#!/bin/bash

FILES=$(ls $2/*.yml 2> /dev/null | wc -l)
if [ "$FILES" -eq "0" ]; then
	echo "$2 does not contain any valid YAML files. Skipping the test."
	exit 0
fi

pushd "$2" > /dev/null

if [[ $1 =~ ansible-playbook ]]; then
	$1 --syntax-check *.yml
	ret=$?
elif [[ $1 =~ ansible-lint ]]; then
	$1 -x 303,204,301,403 -p *.yml
	ret=$?
elif [[ $1 =~ yamllint ]]; then
	$1 -c $3 *.yml
	ret=$?
else
	echo "Error: '$1' is not expected executable" 1>&2
	ret=1
fi

popd > /dev/null
exit $ret
