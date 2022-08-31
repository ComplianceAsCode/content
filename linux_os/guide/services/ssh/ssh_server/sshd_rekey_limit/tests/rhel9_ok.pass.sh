# platform = Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_ospp

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -iq "^\s*RekeyLimit\b" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*RekeyLimit\b/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "RekeyLimit 1G 1h" >> /etc/ssh/sshd_config.d/good_config.conf
