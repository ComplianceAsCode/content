#!/bin/bash

for x in $(find linux_os -name 'rule.yml') ; do
	sed -i '/^\s*cis@rhel[7,8,9]:/d' $x
done
