#!/bin/bash
# packages = audit


echo "-w /run/utmp -p wa -k session" >> /etc/audit/rules.d/login.rules
