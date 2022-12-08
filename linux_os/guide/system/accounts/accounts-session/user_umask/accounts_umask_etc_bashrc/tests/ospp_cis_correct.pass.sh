#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cis, xccdf_org.ssgproject.content_profile_ospp

{{% if 'sle' in product or 'ubuntu' in product %}}
etc_bash_rc="/etc/bash.bashrc"
{{% else %}}
etc_bash_rc="/etc/bashrc"
{{% endif %}}

sed -i '/umask/d' $etc_bash_rc
echo "umask 027" >> $etc_bash_rc
umask 027
