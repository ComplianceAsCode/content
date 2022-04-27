#!/bin/bash
# packages = audit


echo "-w /var/log/something -p wa -k logins" >> /etc/audit/rules.d/login.rules
