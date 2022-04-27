#!/bin/bash
# packages = audit


echo "-w /run/something -p wa -k session" >> /etc/audit/rules.d/login.rules
