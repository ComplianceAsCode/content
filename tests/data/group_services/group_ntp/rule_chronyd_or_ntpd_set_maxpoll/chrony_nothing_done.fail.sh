#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa

yum install -y chrony
yum remove -y ntp

systemctl enable chronyd.service
