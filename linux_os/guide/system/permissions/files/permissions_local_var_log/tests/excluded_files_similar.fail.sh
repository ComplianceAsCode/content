#!/bin/bash

find /var/log -exec chmod g-rwx,o-rwx {} \;

{{% if product in ['ubuntu2004', 'ubuntu2204'] %}}
excluded_files=('2history.log' '2eipp.log.xz' 'btmp1' 'wtmp1' 'lastlog1')
{{% elif product in ['ubuntu2404'] %}}
excluded_files=('btmp1' 'wtmp1' 'lastlog1' '2cloud-init.log''2localmessages' '2waagent.log')
{{% elif product in ['sle12', 'sle15'] %}}
excluded_files=('btmp.1', 'wtmp.1', 'lastlog.1')
{{% endif %}}

for f in ${excluded_files[@]}
do
    touch /var/log/$f
    chmod 777 /var/log/$f
done
