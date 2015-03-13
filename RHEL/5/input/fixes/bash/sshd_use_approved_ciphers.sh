grep -q ^Ciphers /etc/ssh/sshd_config && \
  sed -i "s/Ciphers.*/Ciphers aes128-ctr,aes192-ctr,aes256-ctr/g" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" >> /etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null
