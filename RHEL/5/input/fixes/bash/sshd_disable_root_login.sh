grep -q ^PermitRootLogin /etc/ssh/sshd_config && \
  sed -i "s/PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null