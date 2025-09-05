#!/bin/bash
#
# remediation = bash

sed -i "/.*CREATE_HOME.*/d" /etc/login.defs
