#!/bin/bash

# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# packages = grub2,grubby

source common.sh

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}=correct_value
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=correct_value" %}}
{{%- endif %}}

# adds argument from kernel command line into /etc/default/grub
file="/etc/default/grub"
if grep -q '^GRUB_CMDLINE_LINUX=.*{{{ARG_NAME}}}=.*"'  "$file"; then
	sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\){{{ARG_NAME}}}=[^[:space:]]*\(.*"\)/\1 {{{ARG_NAME_VALUE}}} \2/'  "$file"
else
	sed -i 's/^GRUB_CMDLINE_LINUX=".*/GRUB_CMDLINE_LINUX="{{{ARG_NAME_VALUE}}}"/'  "$file"
fi

# configure the argument in kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*{{{ARG_NAME}}}=.*' "$file"; then
	# modify the GRUB command-line if the arg already exists
	sed -i 's/\(^.*\){{{ARG_NAME}}}=[^[:space:]]*\(.*\)/\1 {{{ARG_NAME_VALUE}}} \2/'  "$file"
else
	# no arg is present, append it
	sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 {{{ARG_NAME_VALUE}}}/'  "$file"
fi


rm -f /boot/loader/entries/*.conf
# setup the first entry with the expanded option
	{
		echo 'title OS 1'
		echo 'version 5.0'
		echo 'linux /vmlinuz'
		echo 'initrd /initramfs'
		echo 'options root=UUID=abc-def rhgb ro quiet mock {{{ARG_NAME_VALUE}}}'
		echo 'grub_users $grub_users'
		echo 'grub_arg --unrestricted'
	} > /boot/loader/entries/mock.conf

# now create a second entry which references grubenv
	{
		echo 'title OS 1'
		echo 'version 5.0'
		echo 'linux /vmlinuz'
		echo 'initrd /initramfs'
		echo 'options root=UUID=abc-def rhgb ro quiet mock $kernelopts'
		echo 'grub_users $grub_users'
		echo 'grub_arg --unrestricted'
	} > /boot/loader/entries/mock2.conf
