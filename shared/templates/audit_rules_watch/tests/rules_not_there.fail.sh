#!/bin/bash
# packages = audit

{{{ setup_augenrules_environment() }}}

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
true
