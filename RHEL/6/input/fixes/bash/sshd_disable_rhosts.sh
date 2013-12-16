grep -q ^IgnoreRhosts /etc/ssh/sshd_config && \
  sed -i "s/IgnoreRhosts.*/IgnoreRhosts yes/g" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config
fi
