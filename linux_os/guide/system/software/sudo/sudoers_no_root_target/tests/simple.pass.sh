# platform = multi_platform_all
# packages = sudo

echo '%wheel ALL=(admin) ALL' > /etc/sudoers
echo 'user ALL=(admin) ALL' > /etc/sudoers.d/foo
