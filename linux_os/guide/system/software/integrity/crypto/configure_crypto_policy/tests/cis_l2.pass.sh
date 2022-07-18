#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_cis,xccdf_org.ssgproject.content_profile_cis_workstation_l2
# packages = crypto-policies-scripts

update-crypto-policies --set "DEFAULT"
