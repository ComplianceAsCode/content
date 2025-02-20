#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

chgrp root /var/log/*
mkdir -p /var/log/apt
chgrp nogroup /var/log/apt
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
mkdir -p /var/log/gdm
chgrp nogroup /var/log/gdm
mkdir -p /var/log/gdm3
chgrp nogroup /var/log/gdm3
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
mkdir -p /var/log/sssd
chgrp nogroup /var/log/sssd
touch /var/log/syslog
chgrp nogroup /var/log/syslog
touch /var/log/waagent.log
touch /var/log/waagent.log.1
chgrp nogroup /var/log/waagent.log*
