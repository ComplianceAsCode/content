# platform = Red Hat Enterprise Linux 7,multi_platform_fedora,Oracle Linux 7
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

PKCSSW="/usr/bin/pkcs11-switch"
MODULE=$(${PKCSSW})

if [ "$MODULE" != "opensc" ] ; then
    echo | ${PKCSSW} opensc
fi

modutil -force -add opensc -dbdir sql:/etc/pki/nssdb -libfile opensc-pkcs11.so
