# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_dir") }}}

{{{ bash_pam_faillock_enable() }}}
{{{ bash_pam_faillock_parameter_value("dir", "$var_accounts_passwords_pam_faillock_dir") }}}

{{{ bash_package_install("python3-libselinux") }}}
{{{ bash_package_install("python3-policycoreutils") }}}
{{{ bash_package_install("policycoreutils-python-utils") }}}

mkdir -p "$var_accounts_passwords_pam_faillock_dir"
semanage fcontext -a -t faillog_t "$var_accounts_passwords_pam_faillock_dir(/.*)?"
restorecon -R -v "$var_accounts_passwords_pam_faillock_dir"
