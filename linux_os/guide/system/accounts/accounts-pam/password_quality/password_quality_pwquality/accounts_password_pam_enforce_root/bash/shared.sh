# platform = Red Hat Enterprise Linux 8,multi_platform_fedora
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

if ! grep -q "^enforce_for_root" /etc/security/pwquality.conf; then
	sed "s/# enforce_for_root/enforce_for_root/g" -i /etc/security/pwquality.conf
fi
