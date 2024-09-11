#!/bin/bash
# platform = multi_platform_all

{{%- if 'ubuntu' in product %}}
# packages = grub2
{{%- else %}}
# packages = grub2,grubby
{{%- endif %}}

source common.sh

# configure the argument in kernel command line in /boot/grub2/grubenv
#file="/boot/grub2/grubenv"
#if grep -q '^.*{{{ARG_NAME}}}=.*' "$file"; then
	# modify the GRUB command-line if the arg already exists
#	sed -i 's/\(^.*\){{{ARG_NAME}}}=[^[:space:]]*\(.*\)/\1 {{{ARG_NAME_VALUE}}} \2/'  "$file"
#else
	# no arg is present, append it
#	sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 {{{ARG_NAME_VALUE}}}/'  "$file"
#fi


# Correct the form of default kernel command line in GRUB /etc/default/grub and applies value through Grubby
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*{{{ ESCAPED_ARG_NAME }}}=.*"'  '/etc/default/grub' ; then
	# modify the GRUB command-line if an arg=value already exists
	sed -i 's/\(^GRUB_CMDLINE_LINUX_DEFAULT=".*\){{{ ARG_NAME }}}=[^[:space:]]*\(.*"\)/\1 {{{ ARG_NAME_VALUE }}} \2/'  '/etc/default/grub'
else
	# no audit=arg is present, append it
	sed -i 's/\(^GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 {{{ ARG_NAME_VALUE }}}"/'  '/etc/default/grub'
fi

# removing the parameter from the no recovery kernel parameters as well
sed -i 's/\(^GRUB_CMDLINE_LINUX=".*\){{{ ARG_NAME }}}=[^[:space:]]*\(.*"\)/\1 \2/'  '/etc/default/grub'

# disabling recovery
sed -i 's/\(^.*GRUB_DISABLE_RECOVERY=\).*/\1true/' '/etc/default/grub'

#if the line is not present at all, add it
if ! grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*$' '/etc/default/grub'; then
	echo 'GRUB_CMDLINE_LINUX_DEFAULT="{{{ ARG_NAME_VALUE }}}"' >> /etc/default/grub
fi

{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}
