#!/bin/bash

function populate {
# code to populate environment variables needed (for unit testing)
if [ -z "${!1}" ]; then
	echo "$1 is not defined. Exiting."
	exit
fi
}
