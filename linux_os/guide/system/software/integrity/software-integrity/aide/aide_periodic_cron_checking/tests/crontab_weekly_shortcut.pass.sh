#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

echo '@weekly    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
