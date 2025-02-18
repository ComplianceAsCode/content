# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

if getent group "adm" >/dev/null 2>&1; then
    group="adm"
else
    group="root"
fi

find -L /var/log/ -maxdepth 1 -regextype posix-extended ! -group root ! -group adm -name '*' ! -path '/var/log/apt/*' ! -name 'auth.log' ! -path '/var/log/[bw]tmp*' ! -path '/var/log/cloud-init.log*' ! -name 'gdm' ! -name 'gdm3' ! -regex '.*\.journal[~]?' ! -regex '.*lastlog(\.[^\/]+)?$' ! -regex '.*localmessages(.*)'  ! -name 'messages' ! -regex '.*secure(.*)' ! -name 'sssd' ! -name 'syslog' ! -regex '.*waagent.log(.*)' -regex '.*' -exec chgrp $group {} \;
