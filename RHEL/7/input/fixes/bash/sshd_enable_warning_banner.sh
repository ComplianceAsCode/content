# platform = Red Hat Enterprise Linux 7
grep -qi ^Banner /etc/ssh/sshd_config && \
  sed -i "s/Banner.*/Banner \/etc\/issue/gI" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "" >> /etc/ssh/sshd_config
    echo "Banner /etc/issue" >> /etc/ssh/sshd_config
fi
