#!/bin/bash

mkdir -p /etc/audit
truncate -s 0 /etc/audit/auditd.conf
touch /etc/audit/auditd.conf
