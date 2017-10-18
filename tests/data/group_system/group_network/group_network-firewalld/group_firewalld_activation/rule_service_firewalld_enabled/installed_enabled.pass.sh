#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

yum install -y firewalld
systemctl enable firewalld.service
