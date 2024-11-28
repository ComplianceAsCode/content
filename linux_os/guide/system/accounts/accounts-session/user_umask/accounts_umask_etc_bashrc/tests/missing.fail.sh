#!/bin/bash
# packages = bash

{{% if 'sle' in product or 'ubuntu' in product or 'debian' in product or product == 'slmicro5' %}}
etc_bash_rc="/etc/bash.bashrc"
{{% else %}}
etc_bash_rc="/etc/bashrc"
{{% endif %}}


sed -i '/umask/d' $etc_bash_rc
