#!/bin/bash

{{% if 'ubuntu' in product %}}
# platform = Not Applicable
{{% endif %}}

# variables = var_accounts_tmout=700

sed -i "/.*TMOUT.*/d" /etc/profile /etc/profile.d/*.sh

echo "typeset -xr TMOUT=700" >> /etc/profile
echo "typeset -xr TMOUT=700" >> /etc/profile.d/tmout.sh
