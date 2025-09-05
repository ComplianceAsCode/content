# platform = multi_platform_fedora
. /usr/share/scap-security-guide/remediation_functions
declare var_accounts_maximum_age_login_defs
populate var_accounts_maximum_age_login_defs

grep -q ^PASS_MAX_DAYS /etc/login.defs && \
sed -i "s/PASS_MAX_DAYS.*/PASS_MAX_DAYS\t$var_accounts_maximum_age_login_defs/g" /etc/login.defs
if ! [ $? -eq 0 ]
then
  echo -e "PASS_MAX_DAYS\t$var_accounts_maximum_age_login_defs" >> /etc/login.defs
fi
