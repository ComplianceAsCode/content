#!/bin/bash
# platform = multi_platform_ubuntu
# packages = auditd

mkdir -p /etc/audit/rules.d
rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
