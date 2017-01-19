# platform = Red Hat Enterprise Linux 7
INCLUDE_SHARED_REMEDIATION_FUNCTIONS
populate var_account_disable_post_pw_expiration

replace_or_append /etc/default/useradd INACTIVE "$var_account_disable_post_pw_expiration" '' '%s=%s'
