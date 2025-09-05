#!/bin/bash
#
# remediation = none
{{% if 'ubuntu' in product %}}
# platform = Not Applicable
{{% endif %}}

UNOWNED_FILES=$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup)

IFS=$"\n"
for f in $UNOWNED_FILES; do
	rm -f "$f"
done

mkdir /sysroot
touch /sysroot/test
chown 9999:9999 /sysroot/test
