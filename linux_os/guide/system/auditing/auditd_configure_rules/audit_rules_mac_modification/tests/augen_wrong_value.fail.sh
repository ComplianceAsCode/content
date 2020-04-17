#!/bin/bash

rm -rf /etc/audit/rules.d/*
echo "-w /etc/group -p w -k MAC-policy" > /etc/audit/rules.d/MAC-policy.rules
