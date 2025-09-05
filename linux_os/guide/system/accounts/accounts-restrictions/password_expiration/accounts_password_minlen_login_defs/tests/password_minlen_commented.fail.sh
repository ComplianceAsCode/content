#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,multi_platform_fedora

sed -i "s/.*PASS_MIN_LEN.*/#PASS_MIN_LEN 12/" /etc/login.defs
