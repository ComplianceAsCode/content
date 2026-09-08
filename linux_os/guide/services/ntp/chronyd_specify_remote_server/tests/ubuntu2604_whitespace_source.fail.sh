#!/bin/bash
# packages = chrony
# platform = Ubuntu 26.04
# remediation = None

rm -rf /etc/chrony/conf.d
rm -rf /etc/chrony/sources.d
mkdir -p /etc/chrony/conf.d /etc/chrony/sources.d

printf 'sourcedir /etc/chrony/sources.d\nconfdir /etc/chrony/conf.d\n' > {{{ chrony_conf_path }}}

# No location contains a source. Neither spaces nor tabs supply a hostname.
# The following directive must not be consumed as a source across a newline.
for config_file in {{{ chrony_conf_path }}} \
    /etc/chrony/sources.d/empty.sources /etc/chrony/conf.d/empty.conf; do
    printf 'server   \npool\t\t\nmakestep 1 3\n' >> "$config_file"
done
