# platform = Red Hat Enterprise Linux 7

if grep --silent ^repo_gpgcheck /etc/yum.conf ; then
        sed -i "s/^repo_gpgcheck.*/repo_gpgcheck=1/g" /etc/yum.conf
else
        echo -e "\n# Set repo_gpgcheck to 1 per security requirements" >> /etc/yum.conf
        echo "repo_gpgcheck=1" >> /etc/yum.conf
fi
