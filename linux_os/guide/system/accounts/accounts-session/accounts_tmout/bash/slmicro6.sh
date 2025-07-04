# platform = multi_platform_slmicro

{{{ bash_instantiate_variables("var_accounts_tmout") }}}

if [ -f /etc/profile.d/autologout.sh ]; then
    if grep --silent '^\s*TMOUT' /etc/profile.d/autologout.sh ; then
        sed -i -E "s/^(\s*)TMOUT\s*=\s*(\w|\$)*(.*)$/\1TMOUT=$var_accounts_tmout\3/g" /etc/profile.d/autologout.sh
    fi
else
    echo -e "\n# Set TMOUT to $var_accounts_tmout per security requirements" >> /etc/profile.d/autologout.sh
    echo "TMOUT=$var_accounts_tmout" >> /etc/profile.d/autologout.sh
fi
if ! grep --silent '^\s*readonly TMOUT' /etc/profile.d/autologout.sh ; then
    echo "readonly TMOUT" >> /etc/profile.d/autologout.sh
fi

if ! grep --silent '^\s*export TMOUT' /etc/profile.d/autologout.sh ; then
    echo "export TMOUT" >> /etc/profile.d/autologout.sh
fi
chmod +x /etc/profile.d/autologout.sh
