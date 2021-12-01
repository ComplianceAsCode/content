#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Oracle Linux 8

authselect select sssd --force
authselect disable-feature with-faillock
