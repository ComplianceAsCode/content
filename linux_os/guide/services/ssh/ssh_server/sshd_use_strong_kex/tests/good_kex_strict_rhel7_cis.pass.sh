# platform = Red Hat Enterprise Linux 7
# profiles = xccdf_org.ssgproject.content_profile_cis

sed -i 's/^\s*KexAlgorithms\s.*//i' /etc/ssh/sshd_config
echo "KexAlgorithms curve25519-sha256" >> /etc/ssh/sshd_config
