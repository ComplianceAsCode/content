#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

yum install -y firewalld
systemctl disable firewalld.service
