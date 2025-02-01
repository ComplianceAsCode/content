# platform = multi_platform_rhel,multi_platform_rhv,multi_platform_fedora,multi_platform_ol,SUSE Linux Enterprise 15,multi_platform_almalinux

sed -i --follow-symlinks "s/selinux=0//gI" /etc/default/grub /etc/grub2.cfg /etc/grub.d/*
sed -i --follow-symlinks "s/enforcing=0//gI" /etc/default/grub /etc/grub2.cfg /etc/grub.d/*
