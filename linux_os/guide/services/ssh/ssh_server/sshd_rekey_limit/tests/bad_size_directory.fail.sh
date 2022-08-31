# platform = multi_platform_fedora,Oracle Linux 9,Red Hat Enterprise Linux 9
# variables = var_rekey_limit_time=1h

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -iq "^\s*RekeyLimit\b" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*RekeyLimit\b/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "RekeyLimit 812M 1h" > /etc/ssh/sshd_config.d/bad_config.conf
