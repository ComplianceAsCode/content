# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,Red Hat Virtualization 4

fips-mode-setup --enable
FIPS_CONF="/etc/dracut.conf.d/40-fips.conf"
if ! grep "^add_dracutmodules+=\" fips \"" $FIPS_CONF; then
    echo "add_dracutmodules+=\" fips \"" >> $FIPS_CONF
fi
