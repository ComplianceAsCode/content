#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp,xccdf_org.ssgproject.content_profile_standard

yum -y install at
systemctl disable atd.service
