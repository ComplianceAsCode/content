#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

# fix logrotate config
sed -i "s/weekly/daily/" /etc/logrotate.conf

# remove default for cron.daily
rm /etc/cron.daily/logrotate
