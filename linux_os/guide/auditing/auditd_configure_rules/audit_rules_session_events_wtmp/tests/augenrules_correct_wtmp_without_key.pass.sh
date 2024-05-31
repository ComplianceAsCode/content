#!/bin/bash
# packages = audit


echo "-w /var/log/wtmp -p wa" >> /etc/audit/rules.d/login.rules
