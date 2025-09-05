# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_rhv
if [ "$(getconf LONG_BIT)" = "32" ] ; then
  #
  # Set runtime for kernel.exec-shield
  #
  sysctl -q -n -w kernel.exec-shield=1

  #
  # If kernel.exec-shield present in /etc/sysctl.conf, change value to "1"
  #	else, add "kernel.exec-shield = 1" to /etc/sysctl.conf
  #
  replace_or_append '/etc/sysctl.conf' '^kernel.exec-shield' '1' '@CCENUM@'
fi

if [ "$(getconf LONG_BIT)" = "64" ] ; then
  if grep --silent noexec /boot/grub2/grub*.cfg ; then 
        sed -i "s/noexec.*//g" /etc/default/grub
        sed -i "s/noexec.*//g" /etc/grub.d/*
        GRUBCFG=/boot/grub2/*.cfg
        grub2-mkconfig -o "$GRUBCFG"
  fi
fi
