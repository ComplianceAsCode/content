# platform = SUSE Enterprise 12
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_maxrepeat

replace_or_append '/etc/security/pwquality.conf' '^maxrepeat' $var_password_pam_maxrepeat 'CCE-27333-4' '%s = %s'
