# platform = multi_platform_rhel, multi_platform_fedora
grep -qi ^IgnoreRhosts /etc/ssh/sshd_config && \
  sed -i "s/IgnoreRhosts.*/IgnoreRhosts yes/gI" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config
fi
