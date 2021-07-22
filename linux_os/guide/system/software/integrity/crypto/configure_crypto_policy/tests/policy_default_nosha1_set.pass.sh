#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_e8

update-crypto-policies --set "DEFAULT:NO-SHA1"
