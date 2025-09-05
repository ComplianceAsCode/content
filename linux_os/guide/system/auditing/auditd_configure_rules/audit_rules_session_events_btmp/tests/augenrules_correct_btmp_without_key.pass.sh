#!/bin/bash
# packages = audit


echo "-w /var/log/btmp -p wa" >> /etc/audit/rules.d/login.rules
