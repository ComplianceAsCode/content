#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

chown root -R /var/log/*

mkdir -p /var/log/apt
touch /var/log/apt/file
chown nobody /var/log/apt/file

touch /var/log/auth.log
chown nobody /var/log/auth.log

touch /var/log/btmp.log
touch /var/log/btmp.log.1
touch /var/log/btmp.log-1
chown nobody /var/log/btmp*

touch /var/log/wtmp.log
touch /var/log/wtmp.log.1
touch /var/log/wtmp.log-1
chown nobody /var/log/wtmp*

touch /var/log/cloud-init.log
touch /var/log/cloud-init.log.1
chown nobody /var/log/cloud-init.log*

touch /var/log/test.journal
touch /var/log/test.journal~
chown nobody /var/log/*.journal*

touch /var/log/lastlog
touch /var/log/lastlog.1
chown nobody /var/log/lastlog*

touch /var/log/localmessages
touch /var/log/localmessages.1
chown nobody /var/log/localmessages*

touch /var/log/messages
chown nobody /var/log/messages

touch /var/log/secure
chown nobody /var/log/secure*

touch /var/log/syslog
chown nobody /var/log/syslog

touch /var/log/waagent.log
touch /var/log/waagent.log.1
chown nobody /var/log/waagent.log*

# see https://workbench.cisecurity.org/benchmarks/18959/tickets/23964
# regarding sssd and gdm exclusions
mkdir -p /var/log/gdm
touch /var/log/gdm/gdm
chown nobody /var/log/gdm/gdm

mkdir -p /var/log/gdm3
touch /var/log/gdm3/gdm3
chown nobody /var/log/gdm3/gdm3

mkdir -p /var/log/sssd
touch /var/log/sssd/sssd
touch /var/log/sssd/SSSD
chown nobody /var/log/sssd/sssd
chown nobody /var/log/sssd/SSSD

