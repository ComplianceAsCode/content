#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_standard
# remediation = none

for x in $(find / -perm /g=s) ; do
	if ! rpm -qf $x ; then
		rm -rf $x
	fi
done
