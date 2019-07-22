# platform = multi_platform_wrlinux,Red Hat Enterprise Linux 6,Red Hat Enterprise Linux 7,Oracle Linux 7,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions
include_lineinfile

sshd_config_set "Ciphers" "aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc"
