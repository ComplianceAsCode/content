# platform = SUSE Enterprise 12
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_ucredit

replace_or_append '/etc/security/pwquality.conf' '^ucredit' $var_password_pam_ucredit 'CCE-27200-5' '%s = %s'
