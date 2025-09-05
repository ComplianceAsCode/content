#!/bin/bash
# packages = audit


echo "-w $path -p wra -k login" >> /etc/audit/rules.d/login.rules
