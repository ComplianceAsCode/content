# platform = multi_platform_rhel,multi_platform_rhv,multi_platform_sle

{{% if product == "rhel7" -%}}
sed -i --follow-symlinks "s/selinux=0//gI" /etc/default/grub /etc/grub2.cfg /etc/grub.d/*
sed -i --follow-symlinks "s/enforcing=0//gI" /etc/default/grub /etc/grub2.cfg /etc/grub.d/*
{{%- elif product == "rhel6" -%}}
sed -i --follow-symlinks "s/selinux=0//gI" /etc/grub.conf
sed -i --follow-symlinks "s/enforcing=0//gI" /etc/grub.conf
{{%- endif -%}}
