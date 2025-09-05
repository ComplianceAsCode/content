#!/bin/bash
#
# platform = multi_platform_rhel,multi_platform_fedora

# The crypto-policies package cannot be normally removed
# from a system, therefore as a part of testing we only
# remove the package without its dependencies.

PKGNAME="crypto-policies"
rpm -e --nodeps "$PKGNAME"
