# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_user_umask

grep -q umask /etc/login.defs && \
  sed -i "s/umask.*/umask $var_accounts_user_umask/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
    echo "umask $var_accounts_user_umask" >> /etc/login.defs
fi
