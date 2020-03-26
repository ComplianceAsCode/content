# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8,Red Hat Virtualization 4
# reboot = true
# strategy = configure
# complexity = low
# disruption = low

rm -f /etc/krb5.conf.d/crypto-policies
ln -s /etc/crypto-policies/back-ends/krb5.config /etc/krb5.conf.d/crypto-policies
