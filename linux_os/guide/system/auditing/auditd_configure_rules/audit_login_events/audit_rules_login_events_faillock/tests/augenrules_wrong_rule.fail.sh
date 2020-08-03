#!/bin/bash


mkdir -p /etc/audit/rules.d
echo "-w /var/run/something -p wa -k logins" >> /etc/audit/rules.d/login.rules
