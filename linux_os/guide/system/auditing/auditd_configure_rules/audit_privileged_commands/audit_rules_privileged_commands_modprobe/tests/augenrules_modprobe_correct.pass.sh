#!/bin/bash
# packages = audit

mkdir -p /etc/audit/rules.d
echo "-w /sbin/modprobe -p x -k modules" >> /etc/audit/rules.d/login.rules
