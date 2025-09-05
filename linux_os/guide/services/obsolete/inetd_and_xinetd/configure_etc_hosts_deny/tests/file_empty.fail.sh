#!/bin/bash

# this is done to ensure that we don't lose ssh connection to the machine
echo "ALL: ALL" > /etc/hosts.allow
# this is the actual test case
echo "" > /etc/hosts.deny
