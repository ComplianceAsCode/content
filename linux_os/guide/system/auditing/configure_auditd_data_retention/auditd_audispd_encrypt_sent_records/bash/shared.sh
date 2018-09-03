# platform = multi_platform_all
. /usr/share/scap-security-guide/remediation_functions

var_enable_krb5="yes"

AUDISP_REMOTE_CONFIG="/etc/audisp/audisp-remote.conf"

replace_or_append $AUDISP_REMOTE_CONFIG '^enable_krb5' "$var_enable_krb5" "@CCENUM@"
