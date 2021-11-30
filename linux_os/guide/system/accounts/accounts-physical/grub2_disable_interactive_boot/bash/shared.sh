# platform = multi_platform_all
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

CONFIRM_SPAWN_YES="systemd.confirm_spawn=\(1\|yes\|true\|on\)"
CONFIRM_SPAWN_NO="systemd.confirm_spawn=no"

if grep -q "\(GRUB_CMDLINE_LINUX\|GRUB_CMDLINE_LINUX_DEFAULT\)" /etc/default/grub
then
	sed -i "s/${CONFIRM_SPAWN_YES}/${CONFIRM_SPAWN_NO}/" /etc/default/grub
fi
# Remove 'systemd.confirm_spawn' kernel argument also from runtime settings
/sbin/grubby --update-kernel=ALL --remove-args="systemd.confirm_spawn"
