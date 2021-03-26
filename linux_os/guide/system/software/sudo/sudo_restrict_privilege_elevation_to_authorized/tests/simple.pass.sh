# platform = SUSE Linux Enterprise 15
# packages = sudo

echo 'user ALL=(admin) ALL' > /etc/sudoers
echo 'user ALL=(admin:admin) ALL' > /etc/sudoers.d/foo
