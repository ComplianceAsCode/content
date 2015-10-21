# platform = Red Hat Enterprise Linux 7
if [ $(getconf LONG_BIT) = "32" ] ; then
  #
  # Set runtime for kernel.exec-shield
  #
  sysctl -q -n -w kernel.exec-shield=1

  #
  # If kernel.exec-shield present in /etc/sysctl.conf, change value to "1"
  #	else, add "kernel.exec-shield = 1" to /etc/sysctl.conf
  #
  if grep --silent ^kernel.exec-shield /etc/sysctl.conf ; then
	sed -i 's/^kernel.exec-shield.*/kernel.exec-shield = 1/g' /etc/sysctl.conf
  else
	echo -e "\n# Set kernel.exec-shield to 1 per security requirements" >> /etc/sysctl.conf
	echo "kernel.exec-shield = 1" >> /etc/sysctl.d/sysctl.conf
  fi
fi

if [ $(getconf LONG_BIT) = "64" ] ; then
  if grep --silent noexec /boot/grub2/grub*.cfg ; then 
        sed -i "s/noexec.*//g" /etc/default/grub
        sed -i "s/noexec.*//g" /etc/grub.d/*
        GRUBCFG=`ls | grep '.cfg$'`
        grub2-mkconfig -o /boot/grub2/$GRUBCFG
  fi
fi
