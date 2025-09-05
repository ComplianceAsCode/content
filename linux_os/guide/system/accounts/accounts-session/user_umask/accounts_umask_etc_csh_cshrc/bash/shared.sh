# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_ol

{{{ bash_instantiate_variables("var_accounts_user_umask") }}}

grep -q "^\s*umask" /etc/csh.cshrc && \
  sed -i -E -e "s/^(\s*umask).*/\1 $var_accounts_user_umask/g" /etc/csh.cshrc
if ! [ $? -eq 0 ]; then
    echo "umask $var_accounts_user_umask" >> /etc/csh.cshrc
fi
