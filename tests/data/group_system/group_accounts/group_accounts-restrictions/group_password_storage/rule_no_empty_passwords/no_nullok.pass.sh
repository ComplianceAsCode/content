#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

sed -i '/nullok/d' /etc/pam.d/system-auth
