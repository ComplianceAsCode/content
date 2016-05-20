# platform = SUSE Enterprise 12
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_dcredit

replace_or_append '/etc/security/pwquality.conf' '^dcredit' $var_password_pam_dcredit 'CCE-27214-6' '%s = %s'
