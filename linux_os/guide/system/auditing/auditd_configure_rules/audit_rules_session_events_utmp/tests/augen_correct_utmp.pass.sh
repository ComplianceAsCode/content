#!/bin/bash

rm -rf /etc/audit/rules.d/*
rm /etc/audit/audit.rules

echo "-w /run/utmp -p wa -k session" >> /etc/audit/rules.d/session.rules

