# platform = multi_platform_rhel,multi_platform_ol,multi_platform_fedora
. /usr/share/scap-security-guide/remediation_functions
populate var_audispd_remote_server

AUDITCONFIG=/etc/audisp/audisp-remote.conf

replace_or_append $AUDITCONFIG '^remote_server' "$var_audispd_remote_server" "@CCENUM@"
