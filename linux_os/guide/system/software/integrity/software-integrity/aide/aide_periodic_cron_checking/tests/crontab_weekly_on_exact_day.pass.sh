#!/bin/bash
# packages = aide{{% if product != 'ubuntu2404' %}},crontabs{{% endif %}}
{{% if product == 'ubuntu2404' %}}
# platform = Not Applicable
{{% endif %}}

echo '21    21    *    *    3    root    {{{ aide_bin_path }}} --check &>/dev/null' >> /etc/crontab
