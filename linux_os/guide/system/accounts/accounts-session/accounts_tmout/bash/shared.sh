# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_wrlinux
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_accounts_tmout") }}}

if grep --silent '^\s*TMOUT' /etc/profile ; then
        sed -i -E "s/^(\s*)TMOUT\s*=\s*(\w|\$)*(.*)$/\1TMOUT=$var_accounts_tmout\3/g" /etc/profile
else
        echo -e "\n# Set TMOUT to $var_accounts_tmout per security requirements" >> /etc/profile
        echo "TMOUT=$var_accounts_tmout" >> /etc/profile
fi
