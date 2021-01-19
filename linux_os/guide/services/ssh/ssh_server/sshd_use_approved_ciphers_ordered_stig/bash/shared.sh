# platform = multi_platform_wrlinux,Red Hat Enterprise Linux 7,Oracle Linux 7

if grep -q -P '^[[:space:]]*[Cc]iphers[[:space:]]+' /etc/ssh/sshd_config; then
  sed -i 's/^\s*[Cc]iphers.*/Ciphers aes256-ctr,aes192-ctr,aes128-ctr/' /etc/ssh/sshd_config
else
  echo "Ciphers aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config
fi
