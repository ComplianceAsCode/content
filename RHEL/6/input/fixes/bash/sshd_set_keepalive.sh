grep -q ^ClientAliveCountMax /etc/ssh/sshd_config && \
  sed -i "s/ClientAliveCountMax.*/ClientAliveCountMax 0/g" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config
fi
