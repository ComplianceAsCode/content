#!/bin/bash


mkdir -p /etc/audit/rules.d
echo "-w /run/utmp -p wa -k session" >> /etc/audit/rules.d/login.rules
