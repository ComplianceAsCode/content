#!/bin/bash

sed -i '/\s*minclass\s*=/d' /etc/security/pwquality.conf
echo "minclass = 0" >> /etc/security/pwquality.conf
