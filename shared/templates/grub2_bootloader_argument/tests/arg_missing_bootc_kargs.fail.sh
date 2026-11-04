#!/bin/bash
# platform = Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10
# packages = bootc,kernel
# remediation = bash
{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_VALUE_PASS }}}
{{%- endif %}}

# Look like a bootable container image being built: the remediation takes
# its bootc branch where /run/.containerenv exists, and the check reads
# /usr/lib/bootc/kargs.d where /run/ostree-booted exists.
touch /run/.containerenv /run/ostree-booted

# kargs.d sets another argument whose name starts with this one.
mkdir -p /usr/lib/bootc/kargs.d
rm -f /usr/lib/bootc/kargs.d/*.toml
echo 'kargs = ["{{{ ARG_NAME }}}_other=1"]' > /usr/lib/bootc/kargs.d/20-other.toml
