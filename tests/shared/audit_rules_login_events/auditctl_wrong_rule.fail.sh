#!/bin/bash
# packages = audit

echo "-w $path -p w -k logins" >> /etc/audit/audit.rules
