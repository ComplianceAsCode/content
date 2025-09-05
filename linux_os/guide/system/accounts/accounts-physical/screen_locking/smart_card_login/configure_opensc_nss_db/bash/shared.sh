# platform = Red Hat Enterprise Linux 7,multi_platform_fedora,Oracle Linux 7
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

PKCSSW=$(/usr/bin/pkcs11-switch)

if [ ${PKCSSW} != "opensc" ] ; then
    ${PKCSSW} opensc
fi
