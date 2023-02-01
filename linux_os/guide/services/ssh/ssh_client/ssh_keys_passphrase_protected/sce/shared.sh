#!/usr/bin/env bash

user_list=$(awk -F: -n '{ if ($7 !~ /\/s?bin\/false/ && $7 !~ /\/s?bin\/nologin/) { print $0; } }' /etc/passwd)
user_dirs=$(cut -d: -f6 <<<"${user_list}" | sort | uniq)
for dir in ${user_dirs}
do
	pubkeys=$(find "${dir}/.ssh/" -type f -name '*.pub')
	for pubkey in ${pubkeys}
	do
		ssh-keygen -y -P "" -f "${pubkey%.pub}" >/dev/null
		if [ $? -ne 255 ]; then
			echo "Key '${pubkey}' is not passphrase-protected"
			exit "${XCCDF_RESULT_FAIL}"
		fi
	done
done

exit "${XCCDF_RESULT_PASS}"
