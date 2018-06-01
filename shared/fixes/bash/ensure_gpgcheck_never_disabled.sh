# platform = multi_platform_rhel,multi_platform_ol
sed -i 's/gpgcheck=.*/gpgcheck=1/g' /etc/yum.repos.d/*
