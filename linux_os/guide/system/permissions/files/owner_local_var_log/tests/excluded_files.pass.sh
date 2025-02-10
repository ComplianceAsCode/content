#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

chown root /var/log/*
mkdir -p /var/log/apt
chown nobody /var/log/apt
touch /var/log/auth.log
chown nobody /var/log/auth.log
touch /var/log/btmp.log
chown nobody /var/log/btmp*
touch /var/log/wtmp.log
chown nobody /var/log/wtmp*
touch /var/log/cloud-init.log
chown nobody /var/log/cloud-init.log*
mkdir -p /var/log/gdm
chown nobody /var/log/gdm
mkdir -p /var/log/gdm3
chown nobody /var/log/gdm3
touch /var/log/test.journal
chown nobody /var/log/*.journal*
touch /var/log/lastlog
chown nobody /var/log/lastlog*
touch /var/log/localmessages
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
chown nobody /var/log/waagent.log*
