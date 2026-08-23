#!/bin/bash

NETRC_FILES=$(find /home -xdev -name .netrc)

IFS=$'\n'
for f in $NETRC_FILES; do
	rm -f "$f"
done
