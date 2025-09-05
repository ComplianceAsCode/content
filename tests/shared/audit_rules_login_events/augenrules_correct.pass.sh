#!/bin/bash
# packages = audit


echo "-w $path -p wa -k login" >> /etc/audit/rules.d/login.rules
