#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ccc

sed -ir '/\*\s+hard\s+core/d' /etc/security/limits.conf
