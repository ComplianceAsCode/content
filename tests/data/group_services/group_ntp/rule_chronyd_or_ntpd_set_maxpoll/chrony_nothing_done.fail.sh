#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig

yum install -y chrony
yum remove -y ntp

systemctl enable chronyd.service
