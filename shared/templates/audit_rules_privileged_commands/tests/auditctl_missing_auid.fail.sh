#!/bin/bash
# packages = audit
source common.sh

{{{ setup_auditctl_environment() }}}

echo "-a always,exit -F path={{{ PATH }}} ${perm_x} -k test_key" >> /etc/audit/audit.rules
