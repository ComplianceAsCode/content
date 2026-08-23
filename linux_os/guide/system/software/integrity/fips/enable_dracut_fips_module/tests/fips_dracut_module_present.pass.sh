#!/bin/bash
# packages = crypto-policies-scripts
# platform = multi_platform_rhel,Red Hat Virtualization 4,multi_platform_ol

fips-mode-setup --enable
FIPS_CONF="/etc/dracut.conf.d/40-fips.conf"
if ! grep "^add_dracutmodules+=\" fips \"" $FIPS_CONF; then
    echo "add_dracutmodules+=\" fips \"" >> $FIPS_CONF
fi
