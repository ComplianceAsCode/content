#!/bin/bash
# platform = multi_platform_ubuntu
# packages = aide

echo sed -i "^SILENTREPORTS\s*=\s*no$" /etc/default/aide
