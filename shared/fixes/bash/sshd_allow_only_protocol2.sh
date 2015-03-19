grep -qi ^Protocol /etc/ssh/sshd_config && \
  sed -i "s/Protocol.*/Protocol 2/gI" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "Protocol 2" >> /etc/ssh/sshd_config
fi
