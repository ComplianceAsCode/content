#!/bin/bash

rm -rf /etc/audit/rules.d/*
rm /etc/audit/audit.rules

echo "-w /var/run/utmp -p wa -k session" >> /etc/audit/rules.d/session.rules
echo "-w /var/log/btmp -p wa -k session" >> /etc/audit/rules.d/session.rules
echo "-w /var/log/wtmp -p wa -k session" >> /etc/audit/rules.d/session.rules

