#!/bin/bash
# packages = audit


echo "-w {{{ PATH }}} -p w -k login" >> /etc/audit/rules.d/login.rules
