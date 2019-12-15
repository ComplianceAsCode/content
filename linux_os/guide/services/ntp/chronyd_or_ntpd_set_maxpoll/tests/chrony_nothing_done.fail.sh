#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig
# platform = Red Hat Enterprise Linux 7

yum install -y chrony
yum remove -y ntp

systemctl enable chronyd.service
