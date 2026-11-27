#!/bin/bash
# packages = audit

# A stray -e directive in another rules file is reported even when it sorts
# before the file carrying "-e 2": OVAL cannot compare file names, so any
# other -e directive is treated as able to override "-e 2".
rm -rf /etc/audit/rules.d/*
echo "-e 1" > /etc/audit/rules.d/10-base.rules
echo "-e 2" > /etc/audit/rules.d/30-immutable.rules
