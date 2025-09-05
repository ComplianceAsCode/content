# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,Red Hat Virtualization 4,Red Hat OpenShift Container Platform 4

if grep -q -m1 -o aes /proc/cpuinfo; then
    {{{ bash_package_install("dracut-fips-aesni") | indent(4) }}}
fi
