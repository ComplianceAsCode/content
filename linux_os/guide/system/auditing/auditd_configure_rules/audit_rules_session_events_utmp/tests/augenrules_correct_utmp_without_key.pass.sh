#!/bin/bash
# packages = audit


echo "-w /run/utmp -p wa" >> /etc/audit/rules.d/login.rules
