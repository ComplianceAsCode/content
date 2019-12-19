#!/bin/bash

if [ ! -f "$1" ] || [ ! -f "$2" ]; then
	printf "Usage: $(basename $0) <DATASTREAM> <UNSELECT_LIST_FILE>
Copies the DATASTREAM file to /tmp and unselects the rules listed
in the UNSELECT_LIST_FILE from the /tmp/DATASTREAM file.\n"
	exit 1
fi
DS=$1
UNSELECT_LIST=$2


printf 'Copying %s file to /tmp\n' "$DS"
cp $DS /tmp || exit 1
DS="/tmp/$(basename $DS)"

printf 'Unselecting rules listed in the %s from the %s\n' "$UNSELECT_LIST" "$DS"
for rule in $(cat $UNSELECT_LIST); do
	sed -i "/<.*Rule id=\"$rule/s/selected=\"true\"/selected=\"false\"/g" $DS || exit 1
	sed -i "/<.*select idref=\"$rule/s/selected=\"true\"/selected=\"false\"/g" $DS || exit 1
done
printf "Done\n"
