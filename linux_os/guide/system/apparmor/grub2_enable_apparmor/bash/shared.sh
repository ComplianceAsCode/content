# platform = multi_platform_ubuntu

{{{ update_etc_default_grub_manually('apparmor', 'apparmor=1') }}}
{{{ update_etc_default_grub_manually('security', 'security=apparmor') }}}

{{% if 'ubuntu' in product %}}
update-grub
{{% else %}}
grub2-mkconfig -o /boot/grub2/grub.cfg
{{% endif %}}
