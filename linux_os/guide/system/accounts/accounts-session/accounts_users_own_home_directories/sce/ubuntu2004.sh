#!/bin/bash
#
# Contributed by Canonical.
#
# Disable job control and run the last command of a pipeline in the current shell environment
# Require Bash 4.2 and later
#
# platform = multi_platform_ubuntu
# check-import = stdout

set +m
shopt -s lastpipe

result=$XCCDF_RESULT_PASS

cat /etc/passwd | egrep -v '^(root|halt|sync|shutdown)' | awk -F: '($7 != "/usr/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }'| while read user dir; do
	if [ ! -d "$dir" ]; then
		echo "The home directory ($dir) of user $user does not exist."
		result=$XCCDF_RESULT_FAIL
		break
	else
		owner=$(stat -L -c "%U" "$dir")
		if [ "$owner" != "$user" ]; then
			echo "The home directory ($dir) of user $user is owned by $owner."
			result=$XCCDF_RESULT_FAIL
			break
		fi
	fi
done
exit $result
