# platform = multi_platform_all
# reboot = true
# strategy = configure
# complexity = low
# disruption = low

rm -f /etc/krb5.conf.d/crypto-policies
ln -s /etc/crypto-policies/back-ends/krb5.config /etc/krb5.conf.d/crypto-policies
