#!/bin/bash
# packages = audit
# platform = multi_platform_rhel
# profiles = xccdf_org.ssgproject.content_profile_cis

path="/var/run/faillock"
. $SHARED/audit_rules_login_events/augenrules_wrong_rule_without_key.fail.sh
