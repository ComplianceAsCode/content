#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# variables = var_password_hashing_algorithm_pam=sha512
# packages = libuser

# Without the libuser package the requirement is not applicable.
dnf remove -y --noautoremove libuser
