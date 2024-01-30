#!/bin/bash
# packages = authselect,pam
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

authselect create-profile test_profile -b sssd
authselect select "custom/test_profile" --force

authselect disable-feature with-faillock

authselect apply-changes
