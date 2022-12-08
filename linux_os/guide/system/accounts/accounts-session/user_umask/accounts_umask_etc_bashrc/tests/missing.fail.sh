#!/bin/bash

{{% if 'sle' in product or 'ubuntu' in product %}}
etc_bash_rc="/etc/bash.bashrc"
{{% else %}}
etc_bash_rc="/etc/bashrc"
{{% endif %}}


sed -i '/umask/d' $etc_bash_rc
