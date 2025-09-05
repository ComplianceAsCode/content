# platform = Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_ospp

sed -e '/RekeyLimit/d' /etc/ssh/sshd_config
echo "RekeyLimit 1G 1h" >> /etc/ssh/sshd_config
