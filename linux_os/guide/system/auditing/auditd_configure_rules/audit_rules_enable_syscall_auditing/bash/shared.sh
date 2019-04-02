# platform = multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions

for f in /etc/audit/audit.rules /etc/audit/rules.d/*.rules ; do
    sed -E -i --follow-symlinks 's/^(\s*-a\s+task,never)/#\1/' "$f"
done
