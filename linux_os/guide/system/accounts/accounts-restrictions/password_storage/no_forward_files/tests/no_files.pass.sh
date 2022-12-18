#!/bin/bash

FORWARD_FILES=$(find /home -xdev -name .forward)

IFS=$'\n'
for f in $FORWARD_FILES; do
	rm -f "$f"
done
