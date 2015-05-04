P11=$(ls -l /etc/alternatives/libnssckbi.so* | awk {'print $11'})
P11LIB="/usr/lib64/pkcs11/p11-kit-trust.so"

if ! [[ ${P11} == ${P11LIB} ]] ; then
   /usr/bin/update-ca-trust enable
fi
