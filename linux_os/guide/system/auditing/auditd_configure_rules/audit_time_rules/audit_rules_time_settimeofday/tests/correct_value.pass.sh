#!/bin/bash


if grep -qv "^[\s]*-a[\s]+always,exit[\s]+-F[\s]+arch=b32.*(-S[\s]+settimeofday[\s]+|([\s]+|[,])settimeofday([\s]+|[,])).*(-k[\s]+|-F[\s]+key=)[\S]+[\s]*$" /etc/audit/rules.d/*.rules; then
	echo "-a always,exit -F arch=b32 -S settimeofday -k audit_time_rules" >> /etc/audit/rules.d/time.rules
	echo "-a always,exit -F arch=b64 -S settimeofday -k audit_time_rules" >> /etc/audit/rules.d/time.rules
fi
