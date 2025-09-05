# platform = multi_platform_all
# packages = sudo

# Allow root to execute commands on behalf of anybody
echo ' root ALL=(ALL) ALL' > /etc/sudoers
echo 'root ALL= ALL' >> /etc/sudoers
echo '# user ALL= ALL' >> /etc/sudoers
