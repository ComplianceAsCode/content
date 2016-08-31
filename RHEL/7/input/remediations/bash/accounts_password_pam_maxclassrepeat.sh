# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_maxclassrepeat

replace_or_append '/etc/security/pwquality.conf' '^maxclassrepeat' $var_password_pam_maxclassrepeat '27512-3' '%s = %s'
