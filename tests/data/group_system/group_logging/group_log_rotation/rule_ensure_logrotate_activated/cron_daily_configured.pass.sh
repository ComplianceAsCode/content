#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

# make sure config in logrotate conf is misconfigured
sed -i "s/daily/weekly/" /etc/logrotate.conf

# default for cron.daily for RHEL7 is already correct
