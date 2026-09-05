#!/bin/bash
# platform = Ubuntu 26.04
# check-import = stdout

result=$XCCDF_RESULT_PASS
found_path=false

while IFS= read -r motd_path; do
    motd_path=${motd_path#\"}; motd_path=${motd_path%\"}
    motd_path=${motd_path#\'}; motd_path=${motd_path%\'}
    found_path=true

    if [[ ! -e "$motd_path" ]]; then
        echo "$motd_path does not exist."
        result=$XCCDF_RESULT_FAIL
        continue
    fi

    read -r mode uid gid < <(stat -Lc '%a %u %g' "$motd_path")
    if (( 8#$mode & 0133 )) || [[ "$uid" != 0 || "$gid" != 0 ]]; then
        echo "$motd_path has mode $mode and owner $uid:$gid; expected root:root and 0644 or more restrictive."
        result=$XCCDF_RESULT_FAIL
    fi
done < <(grep -hPoi '^\h*session\h+(required|optional)\h+pam_motd\.so\b.*\bmotd=\K("[^"]+"|'"'"'[^'"'"']+'"'"'|\S+)' /etc/pam.d/* 2>/dev/null | sort -u)

if [[ "$found_path" != true ]]; then
    echo 'No explicit pam_motd message path was found in /etc/pam.d.'
    result=$XCCDF_RESULT_FAIL
fi

exit "$result"
