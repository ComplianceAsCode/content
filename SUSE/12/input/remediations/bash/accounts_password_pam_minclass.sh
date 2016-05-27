# platform = SUSE Enterprise 12
. /usr/share/scap-security-guide/remediation_functions
populate var_password_pam_minclass

replace_or_append '/etc/security/pwquality.conf' '^minclass' $var_password_pam_minclass 'CCE-27115-5' '%s = %s'
