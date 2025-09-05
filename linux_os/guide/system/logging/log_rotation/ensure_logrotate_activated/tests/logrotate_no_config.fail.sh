#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

sed -i "/^daily/d" /etc/logrotate.conf
rm /etc/cron.daily/logrotate
