#!/bin/bash
# packages = chrony
#
# profiles = xccdf_org.ssgproject.content_profile_stig
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

yum remove -y ntp

systemctl enable chronyd.service
