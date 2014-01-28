grep -qi ^PermitUserEnvironment /etc/ssh/sshd_config && \
  sed -i "s/PermitUserEnvironment.*/PermitUserEnvironment no/gI" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "PermitUserEnvironment no" >> /etc/ssh/sshd_config
fi
