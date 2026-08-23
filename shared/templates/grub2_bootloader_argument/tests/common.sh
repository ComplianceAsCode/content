#!/bin/bash

# this file prepares unified test environment used by other scenarios
# These should be tuned per product to match defaults

{{% if product in ["ol8", "rhel8"] -%}}
mkdir -p /boot/grub2
rm -f /boot/grub2/grubenv
	# File size must be exactly 1KiB
	{
		echo '# GRUB Environment Block'
		echo 'boot_indeterminate=0'
		echo 'boot_success=1'
		echo 'kernelopts=root=UUID=abc-def rhgb ro quiet mock'
		dd if=/dev/zero bs=1K count=1 | tr '\0' '#'
	} > /boot/grub2/grubenv
	truncate --size=1K /boot/grub2/grubenv
{{% endif %}}


mkdir -p /etc/default
rm -f /etc/default/grub
	{
		echo 'GRUB_CMDLINE_LINUX="rhgb ro ouiet"'
		echo 'GRUB_CMDLINE_LINUX_DEFAULT="rhgb ro quiet mock"'
		echo 'GRUB_DEFAULT=saved'
		echo 'GRUB_DISABLE_RECOVERY=true'
		echo 'GRUB_DISABLE_SUBMENU=true'
		echo 'GRUB_ENABLE_BLSCFG=true'
		echo 'GRUB_TIMEOUT=30'
	} > /etc/default/grub

{{% if product in ["fedora", "ol8", "ol9", "rhel8", "rhel9", "rhel10"] -%}}
mkdir -p /boot/loader/entries
shopt -s nullglob
rm -f /boot/loader/entries/*.conf
	{
		echo 'title OS 1'
		echo 'version 5.0'
		echo 'linux /vmlinuz'
		echo 'initrd /initramfs'
		echo 'options root=UUID=abc-def rhgb ro quiet mock'
		echo 'grub_users $grub_users'
		echo 'grub_arg --unrestricted'
	} > /boot/loader/entries/mock.conf
{{%- endif -%}}
