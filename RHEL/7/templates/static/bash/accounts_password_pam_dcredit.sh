# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_dcredit

replace_or_append '/etc/security/pwquality.conf' '^dcredit' $var_password_pam_dcredit 'CCENUM' '%s = %s'
