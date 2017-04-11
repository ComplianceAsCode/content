#!/bin/bash

# simple wrapper above ansible-playbook
# from ansible snippet create similar file like we get after
# oscap generate fix and then run it

[ "$#" -lt 1 ] && {
	echo "Specify ansible snippet!"
	echo "Usage: "
	echo -e "\t$0 <ansible-snippet-file> [ansible-playbook-parameters]"
}
outputFile=$(mktemp)

remediation="$1"
shift

# Add header
echo "---" >> ${outputFile}
echo " - hosts: localhost" >> ${outputFile}
echo "   tasks:" >> ${outputFile}

# Fix indentation
sed  -E 's;^;    ;g' ${remediation} >> ${outputFile}

# Show content
echo "${outputFile}:"
echo "##########"
cat "${outputFile}"
echo "##########"

# Run
ansible-playbook "${outputFile}" "$@"
