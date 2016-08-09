grep -q ^Banner /etc/ssh/sshd_config && \
  sed -i "s/Banner.*/Banner \/etc\/issue/g" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "Banner /etc/issue" >> /etc/ssh/sshd_config
fi
service sshd restart 1>/dev/null