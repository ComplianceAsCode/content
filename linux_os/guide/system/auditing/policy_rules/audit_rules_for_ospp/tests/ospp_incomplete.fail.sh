#!/bin/bash

# These tests are for systems with 30-ospp-v42.rules file installed
if [ ! -f /usr/share/doc/audit*/rules/30-ospp-v42.rules ]; then
    exit 1
fi
cp /usr/share/doc/audit*/rules/10-base-config.rules /etc/audit/rules.d
cp /usr/share/doc/audit*/rules/11-loginuid.rules /etc/audit/rules.d
cp /usr/share/doc/audit*/rules/43-module-load.rules /etc/audit/rules.d
