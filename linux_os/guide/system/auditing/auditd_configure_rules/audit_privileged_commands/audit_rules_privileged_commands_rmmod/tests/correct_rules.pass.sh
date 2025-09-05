#!/bin/bash

echo "-w /sbin/rmmod -p x -k modules" >> /etc/audit/rules.d/modules.rules
