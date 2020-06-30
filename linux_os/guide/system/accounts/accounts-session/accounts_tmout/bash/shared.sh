# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_wrlinux
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_tmout

if grep grep -q "^TMOUT=" /etc/profile.d/tmout.sh ; then
        sed -i "s/^TMOUT.*/TMOUT=$var_accounts_tmout/g" /etc/profile.d/tmout.sh
else
        echo -e "\n# Set TMOUT to $var_accounts_tmout per security requirements" >> /etc/profile.d/tmout.sh
        echo "TMOUT=$var_accounts_tmout" >> /etc/profile.d/tmout.sh
        echo "readonly TMOUT" >> /etc/profile.d/tmout.sh
        echo "export TMOUT" >> /etc/profile.d/tmout.sh
fi
if grep grep -q "^TMOUT=" /etc/profile ; then
        sed -i "/^TMOUT=.*/d" /etc/profile
fi
