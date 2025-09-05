# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_ospp

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing
sed -i '/^\s*RekeyLimit\b/Id' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
echo "RekeyLimit 1G 1h" >> /etc/ssh/sshd_config
