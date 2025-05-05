#!/bin/bash
# platform = multi_platform_ubuntu

find /var/log -exec chmod g-rwx,o-rwx {} \;

{{% if product in ['ubuntu2004', 'ubuntu2204'] %}}
excluded_files=('2history.log' '2eipp.log.xz' 'btmp1' 'wtmp1' 'lastlog1')
{{% elif product in ['ubuntu2404'] %}}
excluded_files=('1btmp' '1wtmp' '1lastlog')
{{% endif %}}

for f in ${excluded_files[@]}
do
    touch /var/log/$f
    chmod 777 /var/log/$f
done
