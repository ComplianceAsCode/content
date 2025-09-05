# platform = multi_platform_all

{{{ bash_instantiate_variables("var_accounts_user_umask") }}}

grep -qE '^[^#]*umask' /etc/profile && \
  sed -i "s/umask.*/umask $var_accounts_user_umask/g" /etc/profile
if ! [ $? -eq 0 ]; then
    echo "umask $var_accounts_user_umask" >> /etc/profile
fi
