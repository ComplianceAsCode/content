# platform = Red Hat Enterprise Linux 6,Red Hat Enterprise Linux 7,Oracle Linux 7

if grep -q -m1 -o aes /proc/cpuinfo; then
    {{{ bash_package_install("dracut-fips-aesni") | indent(4) }}}
fi
