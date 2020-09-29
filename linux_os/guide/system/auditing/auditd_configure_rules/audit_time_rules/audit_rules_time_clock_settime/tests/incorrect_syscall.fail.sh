#!/bin/bash


rm -rf /etc/audit/rules.d/*.rules
echo "-a always,exit -F arch=b32 -S stime -F a0=0x0 -k time-change" >> /etc/audit/rules.d/time.rules
echo "-a always,exit -F arch=b64 -S stime -F a0=0x0 -k time-change" >> /etc/audit/rules.d/time.rules
