#!/bin/bash


echo "-a always,exit -F dir=/var/log/audit/ -F perm=w -F auid>=1000 -F auid!=unset -F key=access-audit-trail" >> /etc/audit/rules.d/var_log_audit.rules
