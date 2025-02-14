#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

chown root /var/log/*
mkdir -p /var/log/apt
chown nobody /var/log/apt
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
mkdir -p /var/log/gdm
chown nobody /var/log/gdm
mkdir -p /var/log/gdm3
chown nobody /var/log/gdm3
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
mkdir -p /var/log/sssd
chown nobody /var/log/sssd
touch /var/log/syslog
chown nobody /var/log/syslog
touch /var/log/waagent.log
touch /var/log/waagent.log.1
chown nobody /var/log/waagent.log*
