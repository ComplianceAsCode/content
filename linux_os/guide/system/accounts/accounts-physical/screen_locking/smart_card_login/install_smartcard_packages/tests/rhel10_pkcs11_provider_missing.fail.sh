#!/bin/bash
# platform = Red Hat Enterprise Linux 10

# The required package is absent.
dnf remove -y --noautoremove pkcs11-provider
