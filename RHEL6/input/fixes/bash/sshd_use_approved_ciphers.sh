grep -qi ^Ciphers /etc/ssh/sshd_config && \
  sed -i "s/Ciphers.*/Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc/gI" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc" >> /etc/ssh/sshd_config
fi
