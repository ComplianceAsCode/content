# platform = multi_platform_ol
# packages = sudo
# remediation = none

echo '%wheel ALL=(ALL) ROLE=sysadm_r ALL' >> /etc/sudoers.d/01-complianceascode.conf
