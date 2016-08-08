# platform = Red Hat Enterprise Linux 6
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_user_umask

grep -q umask /etc/profile && \
  sed -i "s/umask.*/umask $var_accounts_user_umask/g" /etc/profile
if ! [ $? -eq 0 ]; then
    echo "umask $var_accounts_user_umask" >> /etc/profile
fi
