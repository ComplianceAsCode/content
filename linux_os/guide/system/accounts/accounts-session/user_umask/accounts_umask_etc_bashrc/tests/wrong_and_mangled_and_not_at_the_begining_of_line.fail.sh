#!/bin/bash
# packages = bash

# This TS is a regression test for https://github.com/ComplianceAsCode/content/issues/11937

{{% if 'sle' in product or 'ubuntu' in product or 'debian' in product %}}
etc_bash_rc="/etc/bash.bashrc"
{{% else %}}
etc_bash_rc="/etc/bashrc"
{{% endif %}}

sed -i '/umask/d' /etc/bashrc
echo "    [ \`umask\` -eq 0 ] && umask 027022" >> $etc_bash_rc
umask 000
