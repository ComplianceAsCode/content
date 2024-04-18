#!/bin/bash
# packages = audit

rm -rf /etc/audit/rules.d/*
echo "-e 1" > /etc/audit/rules.d/immutable.rules
