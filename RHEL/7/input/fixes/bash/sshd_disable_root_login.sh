grep -qi ^PermitRootLogin /etc/ssh/sshd_config && \
  sed -i "s/PermitRootLogin.*/PermitRootLogin no/gI" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "PermitRootLogin "no >> /etc/ssh/sshd_config
fi
