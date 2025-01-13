#!/bin/bash
# packages = authselect,pam
# platform = Oracle Linux 8,Oracle Linux 9,multi_platform_rhel

authselect create-profile test_profile -b sssd
authselect select "custom/test_profile" --force

authselect enable-feature with-faillock

authselect apply-changes
