#!/bin/bash
# packages = audit
echo "{{{ PARAMETER }}} = {{{ VALUE }}}" >> "/etc/audit/auditd.conf"
echo "{{{ PARAMETER }}} = wrong_value" >> "/etc/audit/auditd.conf"
