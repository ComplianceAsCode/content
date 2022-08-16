# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,SUSE Linux Enterprise 15
# packages = sudo

echo 'Defaults !targetpw' >> /etc/sudoers
echo 'Defaults !rootpw' >> /etc/sudoers
echo 'Defaults !runaspw' >> /etc/sudoers
echo 'Defaults !targetpw' >> /etc/sudoers.d/00-complianceascode.conf
echo 'Defaults !rootpw' >> /etc/sudoers.d/00-complianceascode.conf
echo 'Defaults !runaspw' >> /etc/sudoers.d/00-complianceascode.conf
