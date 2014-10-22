source ./templates/support.sh
populate var_selinux_policy_name

if [ "$var_selinux_policy_name" = "mls" ]; then
yum -y install policycoreutils-python-2.0.83-19.39.el6.x86_64
yum -y install selinux-policy-mls
yum -y install setools
yum -y install netlabel_tools
yum -y install mcstrans
yum -y install audit-libs-python
yum -y install selinux-policy-minimum
yum -y install libsemanage-python
yum -y install policycoreutils-python
yum -y install setools-libs-python
yum -y install setools-console
touch /.autorelabel
sed -i 's/id:5:initdefault:/id:3:initdefault:/g' /etc/inittab
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
sed -i 's/SELINUXTYPE=targeted/SELINUXTYPE=mls/g' /etc/selinux/config
fi
if [ "$var_selinux_policy_name" = "targeted" ]; then
grep -q ^SELINUXTYPE /etc/selinux/config && \
  sed -i "s/SELINUXTYPE=mls/SELINUXTYPE=$var_selinux_policy_name/g" /etc/selinux/config
#if ! [ $? -eq 0 ]; then
#   echo "SELINUXTYPE=$var_selinux_policy_name" >> /etc/selinux/config
#fi
fi

