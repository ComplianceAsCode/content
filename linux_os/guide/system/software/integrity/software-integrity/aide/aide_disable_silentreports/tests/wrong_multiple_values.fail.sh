#!/bin/bash
# platform = multi_platform_ubuntu
# packages = aide

FILE=/etc/default/aide

echo "SILENTREPORTS=no" >> $FILE
echo "SILENTREPORTS=wrong" >> $FILE

