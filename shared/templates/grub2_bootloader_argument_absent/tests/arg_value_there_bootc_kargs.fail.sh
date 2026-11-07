#!/bin/bash
# platform = Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10
# packages = bootc,kernel-core
# remediation = bash

# Look like a bootable container image being built: the remediation takes
# its bootc branch where /run/.containerenv exists, and the check reads
# /usr/lib/bootc/kargs.d where /run/ostree-booted exists.
touch /run/.containerenv /run/ostree-booted

mkdir -p /usr/lib/bootc/kargs.d
rm -f /usr/lib/bootc/kargs.d/*.toml
echo 'kargs = ["{{{ ARG_NAME }}}=1"]' > /usr/lib/bootc/kargs.d/10-test.toml
echo 'match-architectures = ["x86_64", "aarch64", "ppc64le", "s390x"]' >> /usr/lib/bootc/kargs.d/10-test.toml
