#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

sed '2d' ./ordered_by_filter.rules > /etc/audit/rules.d/ospp.rules
