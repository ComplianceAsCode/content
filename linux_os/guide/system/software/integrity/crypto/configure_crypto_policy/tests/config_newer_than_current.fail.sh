#!/bin/bash
# platform = Red Hat Enterprise Linux 8

update-crypto-policies --set "DEFAULT"
sleep 1s
touch /etc/crypto-policies/config
