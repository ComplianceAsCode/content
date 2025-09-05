# platform = Red Hat Enterprise Linux 7,Oracle Linux 7,multi_platform_sle,multi_platform_ubuntu
if grep -q -P '^\s*[Cc]iphers\s+' /etc/ssh/sshd_config; then
  sed -i 's/^\s*[Cc]iphers.*/Ciphers aes256-ctr,aes192-ctr,aes128-ctr/' /etc/ssh/sshd_config
else
  echo "Ciphers aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config
fi
