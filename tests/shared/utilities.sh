#!/bin/bash

# $1: Config file
# $2: The directive beginning, e.g. ClientAliveCountMax
# $3: The whole directive beginning, e.g. "ClientAliveCountMax 0". Escape slashes - the argument is used in sed.
function assert_directive_in_file {
	if grep -q "^$2" "$1"; then
		sed -i "s/^$2.*/$3/" "$1"
	else
		echo "$3" >> "$1"
	fi
}
