# platform = multi_platform_all
# profiles = xccdf_org.ssgproject.content_profile_ospp

sed -e '/RekeyLimit/d' /etc/ssh/sshd_config
echo "RekeyLimit 1G 1h" >> /etc/ssh/sshd_config
