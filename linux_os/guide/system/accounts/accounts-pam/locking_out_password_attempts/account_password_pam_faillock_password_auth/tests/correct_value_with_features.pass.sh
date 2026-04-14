#!/bin/bash
# packages = authselect,pam
# platform = Oracle Linux 8,Oracle Linux 9,multi_platform_rhel,multi_platform_fedora
# remediation = ansible

authselect create-profile test_profile -b sssd
authselect select "custom/test_profile" --force

# Enable multiple features to test the scenario where "authselect current --raw"
# returns a string with spaces (e.g., "custom/test_profile with-faillock with-fingerprint")
authselect enable-feature with-faillock
authselect enable-feature with-fingerprint

authselect apply-changes
