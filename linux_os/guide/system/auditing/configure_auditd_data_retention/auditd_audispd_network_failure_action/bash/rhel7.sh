# platform = Red Hat Enterprise Linux 7

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

populate var_audispd_network_failure_action

replace_or_append /etc/audisp/audisp-remote.conf '^network_failure_action' "$var_audispd_network_failure_action" "@CCENUM@"
