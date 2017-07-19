# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_tmout

if grep --silent ^TMOUT /etc/profile ; then
        sed -i "s/^TMOUT.*/TMOUT=$var_accounts_tmout/g" /etc/profile
else
        echo -e "\n# Set TMOUT to $var_accounts_tmout per security requirements" >> /etc/profile
        echo "TMOUT=$var_accounts_tmout" >> /etc/profile
fi

# Check if 'readonly TMOUT' is not set in /etc/profile
# Add it if it's missing
if ! grep --silent '^\s*readonly\s\+TMOUT\s*$' /etc/profile; then
    echo -e "\n# Set TMOUT to readonly per security requirements" >> /etc/profile
    echo "readonly TMOUT" >> /etc/profile
fi


