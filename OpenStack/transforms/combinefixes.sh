#!/bin/bash

## First argument: directory with .sh scripts
## Second argument: where to put combined xml file

shopt -s nullglob
echo "<fix-group id=\"bash\" system=\"urn:xccdf:fix:script:sh\" xmlns=\"http://checklists.nist.gov/xccdf/1.1\">" > $2

for fixScript in $1/*.sh; do
	fixName=`echo $fixScript | awk -F/ ' { print $NF } ' | awk -F. ' { print $1 }'`
	fixContent=`cat $fixScript`
	echo "<fix rule=\"$fixName\">" >>$2
	cat $fixScript | while read fixLine; do echo $fixLine >>$2; done
	echo "</fix>" >>$2
done

echo "</fix-group>" >>$2
