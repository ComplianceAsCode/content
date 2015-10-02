# platform = multi_platform_rhel, multi_platform_fedora
grep -q ^HostbasedAuthentication /etc/ssh/sshd_config && \
  sed -i "s/HostbasedAuthentication.*/HostbasedAuthentication no/g" /etc/ssh/sshd_config
if ! [ $? -eq 0 ]; then
    echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config
fi
