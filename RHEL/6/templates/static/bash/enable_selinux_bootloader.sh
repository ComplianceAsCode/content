# platform = Red Hat Enterprise Linux 6
sed -i --follow-symlinks "s/selinux=0//gI" /etc/grub.conf
sed -i --follow-symlinks "s/enforcing=0//gI" /etc/grub.conf
