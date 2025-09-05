#!/bin/bash
# packages = audit


echo "-w $path -p wa" >> /etc/audit/rules.d/login.rules
