#!/bin/bash
# packages = polkit
# platform = Red Hat Enterprise Linux 9
# This TS is a regression test for https://issues.redhat.com/browse/RHEL-87606
dnf remove -y polkit-pkla-compat
