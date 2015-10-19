# platform = Red Hat Enterprise Linux 7
grep -qi ^PermitEmptyPasswords /etc/ssh/sshd_config && \
  sed -i "s/PermitEmptyPasswords.*/PermitEmptyPasswords no/gI" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config
fi
