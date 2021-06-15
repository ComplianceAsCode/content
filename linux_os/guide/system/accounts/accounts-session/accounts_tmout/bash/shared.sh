# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_wrlinux
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_accounts_tmout") }}}

# if 0, no occurence of tmout found, if 1, occurence found
tmout_found=0

for f in /etc/profile /etc/profile.d/*.sh; do
    if grep --silent '^\s*TMOUT' $f; then
        sed -i -E "s/^(\s*)TMOUT\s*=\s*(\w|\$)*(.*)$/\1TMOUT=$var_accounts_tmout\3/g" $f
        tmout_found=1
    fi
done

if [ $tmout_found -eq 0 ]; then
        echo -e "\n# Set TMOUT to $var_accounts_tmout per security requirements" >> /etc/profile.d/tmout.sh
        echo "TMOUT=$var_accounts_tmout" >> /etc/profile.d/tmout.sh
fi
