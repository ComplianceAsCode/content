# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions
populate var_account_disable_post_pw_expiration

replace_or_append '/etc/default/useradd' '^INACTIVE' "$var_account_disable_post_pw_expiration" '@CCENUM@' '%s=%s'
