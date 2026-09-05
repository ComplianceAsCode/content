#!/bin/bash
# platform = Ubuntu 26.04
# check-import = stdout

result=$XCCDF_RESULT_PASS
found_entry=false
os_id=$(awk -F= '$1 == "ID" { gsub(/^"|"$/, "", $2); print $2; exit }' /etc/os-release 2>/dev/null)

for service in sshd login su gdm-password; do
    if [[ -f "/etc/pam.d/$service" ]]; then
        pam_file="/etc/pam.d/$service"
    elif [[ -f "/usr/lib/pam.d/$service" ]]; then
        pam_file="/usr/lib/pam.d/$service"
    else
        continue
    fi

    while IFS= read -r line; do
        found_entry=true
        motd_path=$(grep -oP '\bmotd=\K("[^"]+"|'"'"'[^'"'"']+'"'"'|\S+)' <<< "$line" | head -n 1)
        motd_path=${motd_path#\"}; motd_path=${motd_path%\"}
        motd_path=${motd_path#\'}; motd_path=${motd_path%\'}

        if [[ -z "$motd_path" || ! -r "$motd_path" ]]; then
            echo "$pam_file: pam_motd does not reference a readable explicit motd path."
            result=$XCCDF_RESULT_FAIL
            continue
        fi

        unsafe='(\\[vrms]|Ubuntu|Debian|GNU/Linux)'
        [[ -n "$os_id" ]] && unsafe="(\\\\[vrms]|Ubuntu|Debian|GNU/Linux|${os_id})"
        if grep -Piq "$unsafe" "$motd_path"; then
            echo "$motd_path contains operating-system information or a prohibited escape sequence."
            result=$XCCDF_RESULT_FAIL
        fi
    done < <(grep -Pi '^\h*session\h+(required|optional)\h+pam_motd\.so\b' "$pam_file" 2>/dev/null)
done

if [[ "$found_entry" != true ]]; then
    echo 'No active pam_motd entry with an explicit message file was found.'
    result=$XCCDF_RESULT_FAIL
fi

exit "$result"
