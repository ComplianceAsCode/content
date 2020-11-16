# platform = Red Hat Enterprise Linux 8,multi_platform_fedora
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

if ! grep -q "^local_users_only" /etc/security/faillock.conf; then
	sed "s/# local_users_only/local_users_only/g" -i /etc/security/faillock.conf
fi
