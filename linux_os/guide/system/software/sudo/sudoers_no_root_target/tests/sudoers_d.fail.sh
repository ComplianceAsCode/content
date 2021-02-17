# platform = multi_platform_all
# packages = sudo
# remediation = none

echo '%wheel ALL=(admin) ALL' > /etc/sudoers
echo 'user ALL=(ALL) ALL' > /etc/sudoers.d/foo
