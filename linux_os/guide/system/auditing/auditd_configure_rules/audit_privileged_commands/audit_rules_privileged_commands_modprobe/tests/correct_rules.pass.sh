#!/bin/bash

echo "-w /sbin/modprobe -p x -k modules" >> /etc/audit/rules.d/delete.rules
