#!/bin/bash

# These tests are for systems with 30-ospp-v42.rules file installed
if [ ! -f /usr/share/doc/audit*/rules/30-ospp-v42.rules ]; then
    exit 1
fi
rm -rf /etc/audit/rules.d/*
