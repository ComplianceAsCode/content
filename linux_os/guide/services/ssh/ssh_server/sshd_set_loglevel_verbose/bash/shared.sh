# platform = multi_platform_all

grep -q ^LogLevel /etc/ssh/sshd_config && \
  sed -i "s/^LogLevel.*/LogLevel VERBOSE/g" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "LogLevel VERBOSE" >> /etc/ssh/sshd_config
fi
