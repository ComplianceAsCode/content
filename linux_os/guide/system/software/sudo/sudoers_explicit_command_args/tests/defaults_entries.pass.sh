# platform = multi_platform_all
# remediation = none
# packages = sudo

echo 'Defaults  secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/usr/local/go/bin"' > /etc/sudoers
echo 'root    ALL=(root) /bin/bash -c test' >> /etc/sudoers
