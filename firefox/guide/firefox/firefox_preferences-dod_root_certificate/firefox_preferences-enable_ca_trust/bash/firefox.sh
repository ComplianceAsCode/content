# platform = Mozilla Firefox
P11=$(readlink /etc/alternatives/libnssckbi.so*)
P11LIB="/usr/lib/pkcs11/p11-kit-trust.so"
P11LIB64="/usr/lib64/pkcs11/p11-kit-trust.so"

if ! [[ ${P11} == "${P11LIB64}" ]] || ! [[ ${P11} == "${P11LIB}" ]] ; then
   /usr/bin/update-ca-trust enable
fi
