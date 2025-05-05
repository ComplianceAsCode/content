#!/bin/bash
# platform = multi_platform_ubuntu

find /var/log -exec chmod g-rwx,o-rwx {} \;

{{% if product in ['ubuntu2004', 'ubuntu2204'] %}}
excluded_files=('history.log' 'eipp.log.xz' 'btmp' 'btmp.1' 'btmp-1' 'wtmp' 'wtmp.1' 'wtmp-1' 'lastlog' 'lastlog.1')
{{% elif product in ['ubuntu2404'] %}}
excluded_files=('btmp' 'btmp.1' 'btmp-1' 'wtmp' 'wtmp.1' 'wtmp-1' 'lastlog' 'lastlog.1')
{{% endif %}}

for f in ${excluded_files[@]}
do
    touch /var/log/$f
    chmod 777 /var/log/$f
done
