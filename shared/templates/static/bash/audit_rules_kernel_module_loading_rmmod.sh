# platform = Red Hat Enterprise Linux 7, multi_platform_fedora

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'

fix_audit_watch_rule "auditctl" "/usr/sbin/rmmod" "x" "modules"
fix_audit_watch_rule "augenrules" "/usr/sbin/rmmod" "x" "modules"
