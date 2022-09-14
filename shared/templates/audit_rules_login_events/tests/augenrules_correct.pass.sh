#!/bin/bash
# packages = audit


echo "-w {{{ PATH }}} -p wa -k login" >> /etc/audit/rules.d/login.rules
