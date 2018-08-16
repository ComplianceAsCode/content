# platform = Red Hat Enterprise Linux 7

if grep --silent ^localpkg_gpgcheck /etc/yum.conf ; then
        sed -i "s/^localpkg_gpgcheck.*/localpkg_gpgcheck=1/g" /etc/yum.conf
else
        echo -e "\n# Set localpkg_gpgcheck to 1 per security requirements" >> /etc/yum.conf
        echo "localpkg_gpgcheck=1" >> /etc/yum.conf
fi
