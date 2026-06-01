# platform = multi_platform_all

{{{ bash_instantiate_variables("var_accounts_user_umask") }}}

if grep -q "^[^#]*\bumask" "$NEWROOT/etc/bashrc" ; then
    sed -i -E -e "s/^([^#]*\bumask)[[:space:]]+[[:digit:]]+/\1 $var_accounts_user_umask/g" "$NEWROOT/etc/bashrc"
else
    echo "umask $var_accounts_user_umask" >> "$NEWROOT/etc/bashrc"
fi
