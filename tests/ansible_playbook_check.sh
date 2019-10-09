#!/bin/bash

pushd "$2" > /dev/null

if [[ $1 =~ ansible-playbook ]]; then
	$1 --syntax-check $3-playbook-*.yml
	ret=$?
elif [[ $1 =~ ansible-lint ]]; then
	$1 -x 303,204 -p $3-playbook-*.yml
	ret=$?
elif [[ $1 =~ yamllint ]]; then
	$1 -c $4 $3-playbook-*.yml
	ret=$?
else
	echo "Error: '$1' is not expected executable" 1>&2
	ret=1
fi

popd > /dev/null
exit $ret
