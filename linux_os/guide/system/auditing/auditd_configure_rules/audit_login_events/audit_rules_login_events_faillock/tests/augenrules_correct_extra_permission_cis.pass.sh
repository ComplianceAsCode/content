#!/bin/bash
# packages = audit
# platform = Red Hat Enterprise Linux 8, Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_cis

path="/var/run/faillock"
. $SHARED/audit_rules_login_events/augenrules_correct_extra_permission.pass.sh
