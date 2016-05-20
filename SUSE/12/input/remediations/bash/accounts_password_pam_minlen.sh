# platform = SUSE Enterprise 12
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_minlen

replace_or_append '/etc/security/pwquality.conf' '^minlen' $var_password_pam_minlen 'CCE-27293-0' '%s = %s'
