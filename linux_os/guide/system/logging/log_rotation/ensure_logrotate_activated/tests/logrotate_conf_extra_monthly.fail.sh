#!/bin/bash

sed -i "s/weekly/daily/g" /etc/logrotate.conf
echo "monthly" >> /etc/logrotate.conf
