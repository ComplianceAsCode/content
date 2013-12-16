source ./templates/support.sh
populate var_accounts_user_umask

grep -q UMASK /etc/login.defs && \
  sed -i "s/UMASK.*/UMASK $var_accounts_user_umask/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
    echo "UMASK $var_accounts_user_umask" >> /etc/login.defs
fi
