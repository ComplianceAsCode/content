#!/bin/bash
# platform = multi_platform_debian,multi_platform_ubuntu

useradd -m -s /bin/bash test_user_with_shell

chgrp root -R /var/log/*

mkdir -p /var/log/apt
touch /var/log/apt/file
chgrp test_user_with_shell /var/log/apt/file

mkdir -p /var/log/landscape
touch /var/log/landscape/file
chgrp test_user_with_shell /var/log/landscape/file

touch /var/log/auth.log
chgrp test_user_with_shell /var/log/auth.log

touch /var/log/btmp.log
touch /var/log/btmp.log.1
touch /var/log/btmp.log-1
chgrp test_user_with_shell /var/log/btmp*

touch /var/log/wtmp.log
touch /var/log/wtmp.log.1
touch /var/log/wtmp.log-1
chgrp test_user_with_shell /var/log/wtmp*

touch /var/log/cloud-init.log
touch /var/log/cloud-init.log.1
chgrp test_user_with_shell /var/log/cloud-init.log*

touch /var/log/test.journal
touch /var/log/test.journal~
chgrp test_user_with_shell /var/log/*.journal*

touch /var/log/lastlog
touch /var/log/lastlog.1
chgrp test_user_with_shell /var/log/lastlog*

touch /var/log/localmessages
touch /var/log/localmessages.1
chgrp test_user_with_shell /var/log/localmessages*

touch /var/log/messages
chgrp test_user_with_shell /var/log/messages

touch /var/log/secure
chgrp test_user_with_shell /var/log/secure*

touch /var/log/syslog
chgrp test_user_with_shell /var/log/syslog

touch /var/log/waagent.log
touch /var/log/waagent.log.1
chgrp test_user_with_shell /var/log/waagent.log*

# see https://workbench.cisecurity.org/benchmarks/18959/tickets/23964
# regarding sssd and gdm exclusions
mkdir -p /var/log/gdm
touch /var/log/gdm/gdm
chgrp test_user_with_shell /var/log/gdm/gdm

mkdir -p /var/log/gdm3
touch /var/log/gdm3/gdm3
chgrp test_user_with_shell /var/log/gdm3/gdm3

mkdir -p /var/log/sssd
touch /var/log/sssd/sssd
touch /var/log/sssd/SSSD
chgrp test_user_with_shell /var/log/sssd/sssd
chgrp test_user_with_shell /var/log/sssd/SSSD
