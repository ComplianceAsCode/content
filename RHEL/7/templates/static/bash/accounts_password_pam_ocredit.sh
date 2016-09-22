# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_ocredit

replace_or_append '/etc/security/pwquality.conf' '^ocredit' $var_password_pam_ocredit 'CCENUM' '%s = %s'
