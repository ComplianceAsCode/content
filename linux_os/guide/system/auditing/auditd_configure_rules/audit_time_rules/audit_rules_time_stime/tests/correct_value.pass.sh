#!/bin/bash


if grep -qv "^[\s]*-a[\s]+always,exit[\s]+-F[\s]+arch=b32.*(-S[\s]+stime[\s]+|([\s]+|[,])stime([\s]+|[,])).*(-k[\s]+|-F[\s]+key=)[\S]+[\s]*$" /etc/audit/rules.d/*.rules; then
	echo "-a always,exit -F arch=b32 -S stime -k audit_time_rules" >> /etc/audit/rules.d/time.rules
fi
