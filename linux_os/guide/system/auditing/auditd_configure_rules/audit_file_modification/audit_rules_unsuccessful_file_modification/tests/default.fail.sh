#!/bin/bash
# packages = audit
# remediation = bash

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
