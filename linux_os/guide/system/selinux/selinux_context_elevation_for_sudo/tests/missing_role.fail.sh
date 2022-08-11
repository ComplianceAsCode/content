# platform = multi_platform_ol
# packages = sudo
# remediation = none

echo '%wheel ALL=(ALL) TYPE=sysadm_t ALL' >> /etc/sudoers.d/01-complianceascode.conf
