#!/bin/bash
# packages = aide{{% if product != 'ubuntu2404' %}},crontabs{{% endif %}}
{{% if product == 'ubuntu2404' %}}
# platform = Not Applicable
{{% endif %}}

echo '@weekly    root    {{{ aide_bin_path }}} --check &>/dev/null' >> /etc/crontab
