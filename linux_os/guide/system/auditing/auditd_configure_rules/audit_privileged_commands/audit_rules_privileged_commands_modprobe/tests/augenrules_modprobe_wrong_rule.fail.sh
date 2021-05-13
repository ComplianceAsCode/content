#!/bin/bash

mkdir -p /etc/audit/rules.d
echo "-w /sbin/something -p x -k modules" >> /etc/audit/rules.d/login.rules
