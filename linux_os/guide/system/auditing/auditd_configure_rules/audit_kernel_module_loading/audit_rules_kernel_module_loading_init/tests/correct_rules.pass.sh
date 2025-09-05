#!/bin/bash


echo "-a always,exit -F arch=b32 -S init_module -k modules" >> /etc/audit/rules.d/modules.rules
echo "-a always,exit -F arch=b64 -S init_module -k modules" >> /etc/audit/rules.d/modules.rules

