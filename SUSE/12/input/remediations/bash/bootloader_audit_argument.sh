# platform = Red Hat Enterprise Linux 7

# Correct the form of default kernel command line in /etc/default/grub
grep -q ^GRUB_CMDLINE_LINUX=\".*audit=0.*\" /etc/default/grub && \
  sed -i "s/audit=[^[:space:]\+]/audit=1/g" /etc/default/grub
if ! [ $? -eq 0 ]; then
  sed -i "s/\(GRUB_CMDLINE_LINUX=\)\"\(.*\)\"/\1\"\2 audit=1\"/" /etc/default/grub
fi

# Correct the form of kernel command line for each installed kernel
# in the bootloader
/sbin/grubby --update-kernel=ALL --args="audit=1"
