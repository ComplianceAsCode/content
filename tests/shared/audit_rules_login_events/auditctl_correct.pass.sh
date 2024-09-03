#!/bin/bash
# packages = audit

echo "-w $path -p wa -k logins" >> /etc/audit/audit.rules
