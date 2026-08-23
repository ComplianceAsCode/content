#!/bin/bash
# platform = multi_platform_all

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_VALUE_PASS }}}
{{#- Rules that use arg_variable have no =value in ARG_NAME_VALUE, override with dummy #}}
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=" ~ TEST_VALUE_PASS %}}
{{%- endif %}}
{{#- Wrong value: right argument name, wrong value (e.g. audit_backlog_limit=8191) #}}
{{%- set ARG_NAME_VALUE_WRONG= ARG_NAME ~ "=" ~ TEST_VALUE_FAIL %}}

source common.sh

# --- Make oscap fail: set wrong value in /etc/default/grub (recovery disabled) ---
rm -f /etc/default/grub.d/*

# Correct the form of default kernel command line in GRUB /etc/default/grub and applies value through Grubby
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*\<{{{ ARG_NAME }}}\>=\?.*"'  '/etc/default/grub' ; then
	# modify the GRUB command-line if an arg=value already exists
	sed -i 's/\(^GRUB_CMDLINE_LINUX_DEFAULT=".*\)\<{{{ ARG_NAME }}}\>=\?[^[:space:]]*\(.*"\)/\1{{{ ARG_NAME_VALUE_WRONG }}} \2/'  '/etc/default/grub'
else
	# no arg is present, append it
	sed -i 's/\(^GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1{{{ ARG_NAME_VALUE_WRONG }}}"/'  '/etc/default/grub'
fi

# removing the parameter from the no recovery kernel parameters as well
sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\)\<{{{ ARG_NAME }}}\>=\?[^[:space:]]*\(.*"\)/\1 \2/'  '/etc/default/grub'

# disabling recovery
sed -i 's/\(^.*GRUB_DISABLE_RECOVERY=\).*/\1true/' '/etc/default/grub'

#if the line is not present at all, add it
if ! grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=\?.*$' '/etc/default/grub'; then
	echo 'GRUB_CMDLINE_LINUX_DEFAULT="{{{ ARG_NAME_VALUE }}}"' >> /etc/default/grub
fi

{{{ grub_command("update") }}}
