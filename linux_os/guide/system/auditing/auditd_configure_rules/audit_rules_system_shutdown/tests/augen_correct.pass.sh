#!/bin/bash
# packages = audit

echo "-e 2" > /etc/audit/rules.d/immutable.rules
echo "-f 2" >> /etc/audit/rules.d/immutable.rules
