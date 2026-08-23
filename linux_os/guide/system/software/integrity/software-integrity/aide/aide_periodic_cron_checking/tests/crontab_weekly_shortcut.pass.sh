#!/bin/bash
# packages = aide,crontabs
{{%- if product == 'ubuntu2404' %}}
# platform = Not Applicable
{{%- endif %}}

echo '@weekly    root    {{{ aide_bin_path }}} --check &>/dev/null' >> /etc/crontab
