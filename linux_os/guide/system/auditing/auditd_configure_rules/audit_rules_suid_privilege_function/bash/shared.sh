# platform = multi_platform_sle

IFS='
'

for fs in $(df --local --output=target | tail -n +2) ; do
    for f in $(find "$fs" -xdev -type f \( -perm -4000 -o -perm -2000 \) \( -perm -100 -o -perm -10 -o -perm -1 \) ) ; do
        fix_audit_watch_rule auditctl "$f" "xwa" "audit_rules_usergroup_modification"
        fix_audit_watch_rule augenrules "$f" "xwa" "audit_rules_usergroup_modification"
    done
done
