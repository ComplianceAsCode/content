# platform = multi_platform_all
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

{{# products that are available also in a 32 bits form #}}
{{% if "rhel" not in product and product != "fedora" and "ol" not in families %}}
if [ "$(getconf LONG_BIT)" = "32" ] ; then
  #
  # Set runtime for kernel.exec-shield
  #
  sysctl -q -n -w kernel.exec-shield=1

  #
  # If kernel.exec-shield present in /etc/sysctl.conf, change value to "1"
  #	else, add "kernel.exec-shield = 1" to /etc/sysctl.conf
  #
  {{{ bash_replace_or_append('/etc/sysctl.conf', '^kernel.exec-shield', '1') }}}
fi

if [ "$(getconf LONG_BIT)" = "64" ] ; then
    {{{ grub2_bootloader_argument_absent_remediation("noexec") }}}
fi
{{% else %}}
    {{{ grub2_bootloader_argument_absent_remediation("noexec") }}}
{{% endif %}}
