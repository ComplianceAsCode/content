#!/bin/bash

# platform = multi_platform_all

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_VALUE_PASS }}}
{{#- Rules that use arg_variable have no =value in ARG_NAME_VALUE, override with dummy #}}
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=" ~ TEST_VALUE_PASS %}}
{{%- endif %}}

source common.sh

# --- Setup: populate all GRUB configs with correct value (recovery disabled) ---
{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}

# --- Make oscap fail: remove arg from /etc/default/grub ---
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*\<{{{ ARG_NAME }}}\>=\?.*"' '/etc/default/grub' ; then
	sed -i 's/\(^GRUB_CMDLINE_LINUX_DEFAULT=".*\)\<{{{ ARG_NAME }}}\>=\?[^[:space:]]*\(.*"\)/\1 \2/' '/etc/default/grub'
fi

# removing the parameter from the no recovery kernel parameters as well
sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)\<{{{ ARG_NAME }}}\>=\?[^[:space:]]*\(.*"\)/\1 \2/' '/etc/default/grub'

# disabling recovery
sed -i 's/\(^.*GRUB_DISABLE_RECOVERY=\).*/\1true/' '/etc/default/grub'

#if the line is not present at all, add it
if ! grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=\?.*$' '/etc/default/grub'; then
	echo 'GRUB_CMDLINE_LINUX_DEFAULT=""' >> /etc/default/grub
fi
