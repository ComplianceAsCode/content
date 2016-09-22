# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_lcredit

replace_or_append '/etc/security/pwquality.conf' '^lcredit' $var_password_pam_lcredit 'CCENUM' '%s = %s'
