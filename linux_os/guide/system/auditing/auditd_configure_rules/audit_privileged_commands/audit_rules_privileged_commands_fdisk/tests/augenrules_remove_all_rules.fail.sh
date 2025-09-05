#!/bin/bash
# platform = multi_platform_ubuntu
# packages = auditd

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
