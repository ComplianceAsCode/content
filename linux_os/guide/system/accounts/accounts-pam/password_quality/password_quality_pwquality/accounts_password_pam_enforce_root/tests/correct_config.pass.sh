#!/bin/bash
touch /etc/security/pwquality.conf.d/example.conf
echo 'enforce_for_root' > {{{ pwquality_path }}}
