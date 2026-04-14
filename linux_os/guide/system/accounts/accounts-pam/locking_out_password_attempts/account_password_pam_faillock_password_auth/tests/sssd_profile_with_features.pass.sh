#!/bin/bash
# packages = authselect,pam
# platform = Oracle Linux 8,Oracle Linux 9,multi_platform_rhel,multi_platform_fedora

# Simulate a real RHEL system with sssd profile and multiple features enabled
# This is the scenario reported in issue #14600 where "authselect current --raw"
# returns "sssd with-fingerprint with-silent-lastlog"
authselect select sssd --force
authselect enable-feature with-faillock
authselect enable-feature with-fingerprint
authselect enable-feature with-silent-lastlog

authselect apply-changes
