#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

sed -ir '/\*\s+hard\s+core/d' /etc/security/limits.conf
