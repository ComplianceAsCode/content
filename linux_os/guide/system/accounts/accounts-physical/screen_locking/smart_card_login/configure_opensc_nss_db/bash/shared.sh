# platform = Red Hat Enterprise Linux 7,multi_platform_fedora,Oracle Linux 7
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

yum install -y opensc
PKCSSW=$(/usr/bin/pkcs11-switch)

if [ "${PKCSSW}" != "opensc" ] ; then
    /usr/bin/pkcs11-switch opensc
fi
