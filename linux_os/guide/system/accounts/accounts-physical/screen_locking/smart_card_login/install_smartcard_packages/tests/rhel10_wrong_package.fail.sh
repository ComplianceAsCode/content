#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# packages = opensc

# Another smart card package does not satisfy the pkcs11-provider requirement.
dnf remove -y --noautoremove pkcs11-provider
