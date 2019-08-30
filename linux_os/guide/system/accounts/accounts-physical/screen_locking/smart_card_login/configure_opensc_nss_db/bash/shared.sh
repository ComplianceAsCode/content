# platform = Red Hat Enterprise Linux 7,multi_platform_fedora,multi_platform_rhv,Oracle Linux 7
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

modutil -delete "CoolKey PKCS #11 Module" -dbdir sql:/etc/pki/nssdb/ -force || true # ignore errors
modutil -add "OpenSC PKCS #11 Module" -dbdir sql:/etc/pki/nssdb/ -libfile opensc-pkcs11.so -force
