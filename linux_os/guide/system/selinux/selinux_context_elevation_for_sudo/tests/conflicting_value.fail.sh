# platform = multi_platform_ol
# packages = sudo
# remediation = none

echo '%wheel ALL=(ALL) TYPE=sysadm_t ROLE=sysadm_r ALL' >> /etc/sudoers
echo '%wheel ALL=(ALL) TYPE=unconfined_t ROLE=unconfined_r ALL' >> /etc/sudoers.d/01-complianceascode.conf
