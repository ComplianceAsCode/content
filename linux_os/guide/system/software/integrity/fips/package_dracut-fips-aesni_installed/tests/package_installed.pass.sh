#!/bin/bash

if grep -q -m1 -o aes /proc/cpuinfo; then
    {{{ bash_package_install("dracut-fips-aesni") | indent(4) }}}
else
    echo "This test doesn't work in this system, since it doesn'tt support AES instruction set"
    return 1;
fi
