#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

sed -i "s/daily/weekly/" /etc/logrotate.conf
