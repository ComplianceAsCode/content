#!/bin/bash

mkdir -p /etc/audit/rules.d/
echo "-w /etc/sudo -p wa -k actions" >> /etc/audit/rules.d/actions.rules
