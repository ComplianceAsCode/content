#!/bin/bash
# packages = usbguard

echo "allow with-interface match-all { 03:*:* 09:00:* }" >> /etc/usbguard/rules.conf
