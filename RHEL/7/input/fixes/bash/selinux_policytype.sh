source ./templates/support.sh
populate var_selinux_policy_name

grep -q ^SELINUXTYPE /etc/selinux/config && \
  sed -i "s/SELINUXTYPE=.*/SELINUXTYPE=$var_selinux_policy_name/g" /etc/selinux/config
if ! [ $? -eq 0 ]; then
    echo "SELINUXTYPE=$var_selinux_policy_name" >> /etc/selinux/config
fi
