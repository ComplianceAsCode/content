#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = none

sed -i "s/daily/weekly/" /etc/logrotate.conf
rm /etc/cron.daily/logrotate
