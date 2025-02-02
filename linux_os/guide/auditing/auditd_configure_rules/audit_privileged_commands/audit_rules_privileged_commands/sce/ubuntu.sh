#!/usr/bin/env bash
# platform = Ubuntu 24.04
# check-import = stdout

result=$XCCDF_RESULT_PASS

# Get all rules matching regex for privileged commands
# Check if using auditctl or augenrules
regex='^[\s]*-a always,exit (?:-F path=([\S]+))+(?: -F perm=x)? -F auid>={{{ auid }}} -F auid!=(?:4294967295|unset|-1)[\s]+(?:-k[\s]+|-F[\s]+key=)[\S]+[\s]*$'
if grep -Pq '^ExecStartPost=\-\/sbin\/auditctl.*$' /usr/lib/systemd/system/auditd.service; then
    priv_cmd_rules=$(grep -P -- "$regex" /etc/audit/audit.rules)
else
    priv_cmd_rules=$(grep -P -- "$regex" /etc/audit/rules.d/*.rules)
fi

# find all suid commands on device partitions
filter_nodev=$(awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,)
readarray -t partitions < <(findmnt -n -l -k -it "${filter_nodev}" | grep -Pv "noexec|nosuid|/proc($|/.*$)" | awk '{ print $1 }')
for partition in "${partitions[@]}"; do
    while IFS= read -r -d $'\0' priv_cmd; do
        # fail if entry doesn't exist in auditd rules or has duplicates
        nmatches=$(grep -Pc -- "-F path=${priv_cmd}\b" <<< "${priv_cmd_rules}")
        if [[ "${nmatches}" -eq 0 ]]; then
            echo "Entry for binary '${priv_cmd}' not found in auditd rules"
            result=$XCCDF_RESULT_FAIL
        elif [[ "${nmatches}" -gt 1 ]]; then
            echo "Multiple entries for binary '${priv_cmd}' found in auditd rules"
            result=$XCCDF_RESULT_FAIL
        fi
    done < <(find "${partition}" -xdev -type f -perm /6000 -print0)
done

exit $result
