#!/bin/bash

RHOST_FILES=$(find /home -xdev -name .rhost)

IFS=$'\n'
for f in $RHOST_FILES; do
	rm -f "$f"
done
