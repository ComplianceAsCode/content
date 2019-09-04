#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_ospp

file="/etc/ssh/ssh_config.d/02-ospp.conf"
rm -f "$file"
