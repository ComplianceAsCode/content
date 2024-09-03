#!/bin/bash
# packages = audit

echo "-w $path -p wra -k logins" >> /etc/audit/audit.rules
