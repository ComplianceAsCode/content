# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_rhv,multi_platform_sle,multi_platform_slmicro,multi_platform_almalinux,multi_platform_ubuntu

{{% if 'sle' in product or 'slmicro' in product %}}
{{{ bash_replace_or_append('/etc/zypp/zypp.conf', '^solver.upgradeRemoveDroppedPackages', 'true', '%s=%s', cce_identifiers=cce_identifiers) }}}
{{% elif 'ubuntu' in product %}}
sed -i -E "s/(^Unattended-Upgrade::Remove-Unused-Dependencies\s+.*$)/#\1/I" /etc/apt/apt.conf.d/*
sed -i -E "s/(^Unattended-Upgrade::Remove-Unused-Kernel-Packages\s+.*$)/#\1/I" /etc/apt/apt.conf.d/*
echo "Unattended-Upgrade::Remove-Unused-Dependencies \"true\";" >> /etc/apt/apt.conf.d/50unattended-upgrades
echo "Unattended-Upgrade::Remove-Unused-Kernel-Packages \"true\";" >> /etc/apt/apt.conf.d/50unattended-upgrades
{{% else %}}
if grep --silent ^clean_requirements_on_remove {{{ pkg_manager_config_file }}} ; then
        sed -i "s/^clean_requirements_on_remove.*/clean_requirements_on_remove=1/g" {{{ pkg_manager_config_file }}}
else
        echo -e "\n# Set clean_requirements_on_remove to 1 per security requirements" >> {{{ pkg_manager_config_file }}}
        echo "clean_requirements_on_remove=1" >> {{{ pkg_manager_config_file }}}
fi
{{% endif %}}
