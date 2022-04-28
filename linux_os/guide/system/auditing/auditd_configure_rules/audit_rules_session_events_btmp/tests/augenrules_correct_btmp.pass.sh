#!/bin/bash
# packages = audit


echo "-w /var/log/btmp -p wa -k logins" >> /etc/audit/rules.d/login.rules
