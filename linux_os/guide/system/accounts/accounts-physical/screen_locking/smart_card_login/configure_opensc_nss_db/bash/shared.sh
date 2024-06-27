# platform = multi_platform_fedora,Oracle Linux 7
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

PKCSSW=$(/usr/bin/pkcs11-switch)

if [ ${PKCSSW} != "opensc" ] ; then
    echo -e "\n" | ${PKCSSW} opensc
fi
