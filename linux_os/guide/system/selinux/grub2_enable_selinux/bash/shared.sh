# platform = SUSE Linux Enterprise 15,SUSE Linux Enterprise 16,multi_platform_almalinux,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_rhv

sed -i --follow-symlinks "s/selinux=0//gI" /etc/default/grub /etc/grub2.cfg /etc/grub.d/*
sed -i --follow-symlinks "s/enforcing=0//gI" /etc/default/grub /etc/grub2.cfg /etc/grub.d/*
