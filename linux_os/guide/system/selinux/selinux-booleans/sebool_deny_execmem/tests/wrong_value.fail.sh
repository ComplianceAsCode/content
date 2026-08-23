#!/bin/bash
# variables = var_deny_execmem=true
# remediation = none

setsebool -P deny_execmem false
