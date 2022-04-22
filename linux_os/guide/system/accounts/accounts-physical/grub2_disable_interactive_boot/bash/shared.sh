# platform = multi_platform_all
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

# Verify that Interactive Boot is Disabled in /etc/default/grub
CONFIRM_SPAWN_YES="systemd.confirm_spawn=\(1\|yes\|true\|on\)"
CONFIRM_SPAWN_NO="systemd.confirm_spawn=no"

if grep -q "\(GRUB_CMDLINE_LINUX\|GRUB_CMDLINE_LINUX_DEFAULT\)" /etc/default/grub
then
	sed -i "s/${CONFIRM_SPAWN_YES}/${CONFIRM_SPAWN_NO}/" /etc/default/grub
fi

# make sure GRUB_DISABLE_RECOVERY=true
if grep -q '^GRUB_DISABLE_RECOVERY=.*'  '/etc/default/grub' ; then
       # modify the GRUB command-line if an GRUB_DISABLE_RECOVERY= arg already exists
       sed -i 's/GRUB_DISABLE_RECOVERY=.*/GRUB_DISABLE_RECOVERY=true/' /etc/default/grub
else
       # no GRUB_DISABLE_RECOVERY=arg is present, append it to file
       echo "GRUB_DISABLE_RECOVERY=true"  >> '/etc/default/grub'
fi


{{% if 'sle' in product %}}
#Verify that Interactive Boot is Disabled (runtime)
/usr/bin/grub2-editenv - unset systemd.confirm_spawn

#Verify that GRUB_DISABLE_RECOVERY is Disabled (runtime)
grub2-mkconfig -o /boot/grub2/grub.cfg

{{% else %}}
# Remove 'systemd.confirm_spawn' kernel argument also from runtime settings
/sbin/grubby --update-kernel=ALL --remove-args="systemd.confirm_spawn"

#Verify that GRUB_DISABLE_RECOVERY is Disabled (runtime)
/sbin/grubby --update-kernel=ALL --args="GRUB_DISABLE_RECOVERY=true"
{{% endif %}}
