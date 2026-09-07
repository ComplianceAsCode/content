#!/bin/bash
# platform = Ubuntu 26.04
# packages = aide

aide --init
cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
echo 'database=file:/var/lib/aide/aide.db' >> /etc/aide/aide.conf
