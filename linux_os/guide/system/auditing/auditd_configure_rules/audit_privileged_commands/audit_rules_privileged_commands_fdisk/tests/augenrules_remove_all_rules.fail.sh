#!/bin/bash
# platform = multi_platform_ubuntu
# packages = audit

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
