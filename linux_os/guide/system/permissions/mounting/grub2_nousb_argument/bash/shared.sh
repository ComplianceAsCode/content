{{%- set nousb_argument = 'nousb' %}}
{{%- if product in ["rhel10"] %}}
{{%- set nousb_argument = 'coreusb.nousb' %}}
{{%- endif %}}
# platform = multi_platform_fedora,multi_platform_rhel

# Correct the form of default kernel command line in /etc/default/grub
if ! grep -q '^GRUB_CMDLINE_LINUX=".*{{{ nousb_argument }}}.*"' /etc/default/grub;
then
  # Edit configuration setting
  # Append '{{{ nousb_argument }}}' argument to /etc/default/grub (if not present yet)
  sed -i "s/\(GRUB_CMDLINE_LINUX=\)\"\(.*\)\"/\1\"\2 {{{ nousb_argument }}}\"/" /etc/default/grub
  # Edit runtime setting
  # Correct the form of kernel command line for each installed kernel in the bootloader
  /sbin/grubby --update-kernel=ALL --args="{{{ nousb_argument }}}"
fi
