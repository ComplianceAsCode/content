#!/bin/bash

[ "$#" -lt 3 ] && {
	echo "Usage:"
	echo -e "\t$0 <original directory> <target directory> <path replacement ';' as separator>"

	echo "Example:"
	echo -e "\t$0 ./bash ./ansible '/(.*).sh;/\\1.yml'"
	echo ""
	echo "This file show 'diff' between directories & show not translated remediations"
	exit 1
}





originalDir="$1"
newDir="$2"
replace="$3"

find "$originalDir" | while read originalFilename;
do
	targetFilename=$(echo "$originalFilename" | sed "s;$originalDir;$newDir;g" | sed -r "s;$replace;")
	if [ -f "$targetFilename" ];
	then
		echo -e "[OK]\t$originalFilename\t$targetFilename" 
	else
		echo -e "[MISS]\t$originalFilename\t$targetFilename" 
	fi
done
