echo "AllowGroups wheel" | tee -a /etc/ssh/sshd_config &>/dev/null
service sshd restart 1>/dev/null