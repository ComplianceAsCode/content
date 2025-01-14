#!/bin/bash
# packages = audit
# platform = multi_platform_rhel
# profiles = xccdf_org.ssgproject.content_profile_cis

{{{ setup_auditctl_environment() }}}

path="/var/run/faillock"
. $SHARED/audit_rules_login_events/auditctl_correct_without_key.pass.sh
