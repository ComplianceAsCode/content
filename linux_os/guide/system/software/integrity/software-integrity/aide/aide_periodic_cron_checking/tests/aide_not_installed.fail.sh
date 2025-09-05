#!/bin/bash
# packages = aide,crontabs

{{{ bash_package_remove("aide") }}}

{{% if product == 'ubuntu2404' %}}
echo 'SCRIPT="/usr/share/aide/bin/dailyaidecheck"' > /etc/crontab
{{% else %}}
echo '21    21    *    *    *    root    {{{ aide_bin_path }}} --check &>/dev/null' >> /etc/crontab
{{% endif %}}
