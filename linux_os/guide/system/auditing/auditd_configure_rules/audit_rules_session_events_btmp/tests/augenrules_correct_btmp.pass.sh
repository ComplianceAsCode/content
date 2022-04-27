#!/bin/bash
# packages = audit


mkdir -p /etc/audit/rules.d
echo "-w /var/log/btmp -p wa -k logins" >> /etc/audit/rules.d/login.rules
