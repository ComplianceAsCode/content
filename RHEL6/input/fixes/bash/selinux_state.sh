source ./templates/support.sh
populate var_selinux_state

grep -q ^SELINUX= /etc/selinux/config && \
  sed -i "s/SELINUX=.*/SELINUX=$var_selinux_state/g" /etc/selinux/config
if ! [ $? -eq 0 ]; then
    echo "SELINUX=$var_selinux_state" >> /etc/selinux/config
fi
