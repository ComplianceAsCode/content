# platform = multi_platform_fedora
. /usr/share/scap-security-guide/remediation_functions
declare var_accounts_password_warn_age_login_defs
{{{ bash_instantiate_variables("var_accounts_password_warn_age_login_defs") }}}

grep -q ^PASS_WARN_AGE /etc/login.defs && \
sed -i "s/PASS_WARN_AGE.*/PASS_WARN_AGE\t$var_accounts_password_warn_age_login_defs/g" /etc/login.defs
if ! [ $? -eq 0 ]
then
  echo -e "PASS_WARN_AGE\t$var_accounts_password_warn_age_login_defs" >> /etc/login.defs
fi
