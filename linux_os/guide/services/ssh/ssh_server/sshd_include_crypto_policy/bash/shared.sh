# platform = multi_platform_all

dnf -y remove openssh-server
dnf -y install openssh-server
systemctl restart sshd.service
