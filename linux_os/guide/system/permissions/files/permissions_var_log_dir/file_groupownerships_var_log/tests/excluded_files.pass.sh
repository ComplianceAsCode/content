#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

chgrp root -R /var/log/*

mkdir -p /var/log/apt
touch /var/log/apt/file
chgrp nogroup /var/log/apt/file

touch /var/log/auth.log
chgrp nogroup /var/log/auth.log

touch /var/log/btmp.log
touch /var/log/btmp.log.1
touch /var/log/btmp.log-1
chgrp nogroup /var/log/btmp*

touch /var/log/wtmp.log
touch /var/log/wtmp.log.1
touch /var/log/wtmp.log-1
chgrp nogroup /var/log/wtmp*

touch /var/log/cloud-init.log
touch /var/log/cloud-init.log.1
chgrp nogroup /var/log/cloud-init.log*

touch /var/log/test.journal
touch /var/log/test.journal~
chgrp nogroup /var/log/*.journal*

touch /var/log/lastlog
touch /var/log/lastlog.1
chgrp nogroup /var/log/lastlog*

touch /var/log/localmessages
touch /var/log/localmessages.1
chgrp nogroup /var/log/localmessages*

touch /var/log/messages
chgrp nogroup /var/log/messages

touch /var/log/secure
chgrp nogroup /var/log/secure*

touch /var/log/syslog
chgrp nogroup /var/log/syslog

touch /var/log/waagent.log
touch /var/log/waagent.log.1
chgrp nogroup /var/log/waagent.log*

# see https://workbench.cisecurity.org/benchmarks/18959/tickets/23964
# regarding sssd and gdm exclusions
mkdir -p /var/log/gdm
touch /var/log/gdm/gdm
chgrp nogroup /var/log/gdm/gdm

mkdir -p /var/log/gdm3
touch /var/log/gdm3/gdm3
chgrp nogroup /var/log/gdm3/gdm3

mkdir -p /var/log/sssd
touch /var/log/sssd/sssd
touch /var/log/sssd/SSSD
chgrp nogroup /var/log/sssd/sssd
chgrp nogroup /var/log/sssd/SSSD

