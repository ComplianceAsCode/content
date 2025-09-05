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
# Workaround for https://github.com/OpenSCAP/openscap/issues/2242: Use full
# path to semanage and restorecon commands to avoid the issue with the command
# not being found.
/usr/sbin/semanage fcontext -a -t faillog_t "$var_accounts_passwords_pam_faillock_dir(/.*)?"
/usr/sbin/restorecon -R -v "$var_accounts_passwords_pam_faillock_dir"
