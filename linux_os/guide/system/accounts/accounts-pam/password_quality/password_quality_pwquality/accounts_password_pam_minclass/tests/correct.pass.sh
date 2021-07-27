#!/bin/bash
# packages = {{{- ssgts_package("pam_pwquality") -}}}

sed -i '/\s*minclass\s*=/d' /etc/security/pwquality.conf
echo "minclass = 4" >> /etc/security/pwquality.conf
