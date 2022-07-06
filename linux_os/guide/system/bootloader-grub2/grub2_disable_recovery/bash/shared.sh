# platform = multi_platform_all
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

if grep -q '^GRUB_DISABLE_RECOVERY=.*'  '/etc/default/grub' ; then
    sed -i 's/GRUB_DISABLE_RECOVERY=.*/GRUB_DISABLE_RECOVERY=true/' "/etc/default/grub"
else
    echo "GRUB_DISABLE_RECOVERY=true" >> '/etc/default/grub'
fi

{{{ grub_command("update") }}}
