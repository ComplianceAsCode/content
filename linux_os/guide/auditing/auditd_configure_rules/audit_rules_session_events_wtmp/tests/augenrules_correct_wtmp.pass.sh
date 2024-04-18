#!/bin/bash
# packages = audit


echo "-w /var/log/wtmp -p wa -k logins" >> /etc/audit/rules.d/login.rules
