# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_minlen

replace_or_append '/etc/security/pwquality.conf' '^minlen' $var_password_pam_minlen 'CCENUM' '%s = %s'
