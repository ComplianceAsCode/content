#!/bin/bash
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_e8
# packages = crypto-policies-scripts

update-crypto-policies --set "DEFAULT:NO-SHA1"
