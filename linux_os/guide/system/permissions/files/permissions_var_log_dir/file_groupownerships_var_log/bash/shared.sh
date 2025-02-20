# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

# default to root
group="root"

# see https://workbench.cisecurity.org/benchmarks/18959/tickets/23964
# regarding sssd and gdm exclusions

find -L /var/log/ -type f -regextype posix-extended \
    ! -group root ! -group adm  \
    ! -name 'gdm' ! -name 'gdm3' \
    ! -name 'sssd' ! -name 'SSSD' \
    ! -name 'auth.log' \
    ! -name 'messages' \
    ! -name 'syslog' \
    ! -path '/var/log/apt/*' \
    ! -path '/var/log/gdm/*' \
    ! -path '/var/log/gdm3/*' \
    ! -path '/var/log/sssd/*' \
    ! -path '/var/log/[bw]tmp*' \
    ! -path '/var/log/cloud-init.log*' \
    ! -regex '.*\.journal[~]?' \
    ! -regex '.*/lastlog(\.[^\/]+)?$' \
    ! -regex '.*/localmessages(.*)' \
    ! -regex '.*/secure(.*)' \
    ! -regex '.*/waagent.log(.*)' \
    -regex '.*' -exec chgrp $group {} \;
