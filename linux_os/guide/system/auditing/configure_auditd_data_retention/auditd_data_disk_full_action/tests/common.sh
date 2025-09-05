#!/bin/bash

truncate -s 0 /etc/audit/auditd.conf
mkdir /etc/audit/
touch /etc/audit/auditd.conf
