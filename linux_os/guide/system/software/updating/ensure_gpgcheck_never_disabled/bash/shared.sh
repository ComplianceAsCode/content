# platform = multi_platform_rhel,multi_platform_ol,multi_platform_fedora
sed -i 's/gpgcheck\s*=.*/gpgcheck=1/g' /etc/yum.repos.d/*
