#!/bin/bash


echo "-a always,exit -F dir=/var/log/auditd/ -F perm=r -F auid>=1000 -F auid!=unset -F key=access-audit-trail" >> /etc/audit/rules.d/var_log_audit.rules
