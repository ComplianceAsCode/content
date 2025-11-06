#!/bin/bash
# packages = audit

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules

printf '%s\n' "-c" >> /etc/audit/rules.d/01-initialize.rules
