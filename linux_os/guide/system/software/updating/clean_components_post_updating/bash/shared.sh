# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_rhv,multi_platform_sle

{{% if 'sle' in product %}}
{{{ bash_replace_or_append('/etc/zypp/zypp.conf', '^solver.upgradeRemoveDroppedPackages', 'true', '%s=%s') }}}
{{% else %}}
if grep --silent ^clean_requirements_on_remove {{{ pkg_manager_config_file }}} ; then
        sed -i "s/^clean_requirements_on_remove.*/clean_requirements_on_remove=1/g" {{{ pkg_manager_config_file }}}
else
        echo -e "\n# Set clean_requirements_on_remove to 1 per security requirements" >> {{{ pkg_manager_config_file }}}
        echo "clean_requirements_on_remove=1" >> {{{ pkg_manager_config_file }}}
fi
{{% endif %}}
