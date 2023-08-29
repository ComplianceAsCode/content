#!/bin/bash
# packages = audit


echo "-w $path -p w -k login" >> /etc/audit/rules.d/login.rules
