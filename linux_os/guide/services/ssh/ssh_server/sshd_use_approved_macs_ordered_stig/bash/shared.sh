# platform = multi_platform_wrlinux,Red Hat Enterprise Linux 7,Oracle Linux 7

if grep -q -P '^[[:space:]]*MACs[[:space:]]+' /etc/ssh/sshd_config; then
  sed -i 's/^\s*MACs.*/MACs hmac-sha2-512,hmac-sha2-256/' /etc/ssh/sshd_config
else
  echo "MACs hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/sshd_config
fi
