#!/bin/bash

# We need to mock these files if they do not exist yet
# Because:
# - it is not possible to setup kernel / grub env properly in containerized env
# - even if it would be possible, it takes long time

# These should be tuned per product to match defaults

mkdir -p /boot/grub2
if [ ! -f /boot/grub2/grubenv ]; then
	# File size must be exactly 1KiB
	{
		echo '# GRUB Environment Block'
		echo 'boot_indeterminate=0'
		echo 'boot_success=1'
		echo 'kernelopts=root=UUID=abc-def rhgb ro quiet mock'
		dd if=/dev/zero bs=1K count=1 | tr '\0' '#'
	} > /boot/grub2/grubenv
	truncate --size=1K /boot/grub2/grubenv
fi

mkdir -p /etc/default
if [ ! -f /etc/default/grub ]; then
	{
		echo 'GRUB_CMDLINE_LINUX="rhgb ro ouiet"'
		echo 'GRUB_CMDLINE_LINUX_DEFAULT="rhgb ro quiet mock"'
		echo 'GRUB_DEFAULT=saved'
		echo 'GRUB_DISABLE_RECOVERY=true'
		echo 'GRUB_DISABLE_SUBMENU=true'
		echo 'GRUB_ENABLE_BLSCFG=true'
		echo 'GRUB_TIMEOUT=30'
	} > /etc/default/grub
fi

mkdir -p /boot/loader/entries
shopt -s nullglob
boot_loader_entries=(/boot/loader/entries/*.conf)
if [ "${#boot_loader_entries[@]}" -eq 0 ]; then
	{
		echo 'title OS 1'
		echo 'version 5.0'
		echo 'linux /vmlinuz'
		echo 'initrd /initramfs'
		echo 'options root=UUID=abc-def rhgb ro quiet mock'
		echo 'grub_users $grub_users'
		echo 'grub_arg --unrestricted'
	} > /boot/loader/entries/mock.conf
fi
