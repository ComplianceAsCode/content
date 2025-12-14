#!/bin/bash
mkdir -p /etc/security/pwquality.conf.d
sed -i '/enforce_for_root/d' /etc/security/pwquality.conf.d/*.conf {{{ pwquality_path }}}
echo '#enforce_for_root' > {{{ pwquality_path }}}
