# platform = multi_platform_ol
# reboot = false
# strategy = enable
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_secure_mode_insmod") }}}
setsebool -P secure_mode_insmod $var_secure_mode_insmod

# Preload vfat in initramfs, otherwise the system fails to reboot
echo "vfat" >> /etc/modules-load.d/vfat.conf
dracut -f --regenerate-all
