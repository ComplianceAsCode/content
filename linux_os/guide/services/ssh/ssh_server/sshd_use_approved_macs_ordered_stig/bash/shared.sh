# platform = Red Hat Enterprise Linux 7,Oracle Linux 7,multi_platform_sle,multi_platform_ubuntu
if grep -q -P '^\s*MACs\s+' /etc/ssh/sshd_config; then
  sed -i 's/^\s*MACs.*/MACs hmac-sha2-512,hmac-sha2-256/' /etc/ssh/sshd_config
else
  echo "MACs hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/sshd_config
fi
