#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

# fix logrotate config
sed -i "s/weekly/daily/" /etc/logrotate.conf

# default for cron.daily for RHEL7 is already correct
