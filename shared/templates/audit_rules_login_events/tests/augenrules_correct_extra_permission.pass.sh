#!/bin/bash
# packages = audit


echo "-w {{{ PATH }}} -p wra -k login" >> /etc/audit/rules.d/login.rules
