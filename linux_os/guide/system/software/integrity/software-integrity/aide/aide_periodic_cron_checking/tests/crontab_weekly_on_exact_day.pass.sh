#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

echo '21    21    *    *    3    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
