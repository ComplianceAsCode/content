# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_ospp

sed -i '/RekeyLimit/d' /etc/ssh/sshd_config
echo "RekeyLimit 1G 1h" >> /etc/ssh/sshd_config
