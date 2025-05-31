#!/bin/bash
# packages = aide,crontabs
{{%- if product == 'ubuntu2404' %}}
# platform = Not Applicable
{{%- endif %}}

echo '@daily    root    {{{ aide_bin_path }}} --check &>/dev/null' >> /etc/crontab
