#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

sort ./ordered_by_filter.rules > /etc/audit/rules.d/unsuccessful_open.rules
