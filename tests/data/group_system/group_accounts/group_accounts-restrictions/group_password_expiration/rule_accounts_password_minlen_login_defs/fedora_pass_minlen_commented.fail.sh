#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_standard
# platform = multi_platform_fedora

sed -i "s/.*PASS_MIN_LEN.*/#PASS_MIN_LEN 12/" /etc/login.defs
