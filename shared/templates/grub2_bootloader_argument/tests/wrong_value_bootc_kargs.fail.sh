#!/bin/bash
{{% if not ARG_VALUE and not ARG_VARIABLE %}}
# platform = Not Applicable
{{% else %}}
# platform = Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10
{{% endif %}}
# packages = bootc,kernel
# remediation = bash
{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_VALUE_PASS }}}
{{%- endif %}}
{{%- set ARG_NAME_VALUE_WRONG = ARG_NAME ~ "=" ~ TEST_VALUE_FAIL %}}

# Look like a bootable container image being built: the remediation takes
# its bootc branch where /run/.containerenv exists, and the check reads
# /usr/lib/bootc/kargs.d where /run/ostree-booted exists.
touch /run/.containerenv /run/ostree-booted

# The file that the remediation writes sets a wrong value, followed by
# another argument.
mkdir -p /usr/lib/bootc/kargs.d
rm -f /usr/lib/bootc/kargs.d/*.toml
echo 'kargs = ["{{{ ARG_NAME_VALUE_WRONG }}}", "quiet"]' > /usr/lib/bootc/kargs.d/10-{{{ ARG_NAME_UNDERSCORED }}}.toml
