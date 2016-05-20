# platform = SUSE Enterprise 12
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_difok

replace_or_append '/etc/security/pwquality.conf' '^difok' $var_password_pam_difok 'CCE-26631-2' '%s = %s'
