# platform = multi_platform_rhel
grep -qi ^MACs /etc/ssh/sshd_config && \
  sed -i "s/MACs.*/MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1/gI" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1" >> /etc/ssh/sshd_config
fi
