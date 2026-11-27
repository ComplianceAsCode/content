#!/bin/bash
# packages = aide
# platform = multi_platform_debian,multi_platform_ubuntu

sed -i "s/^Checksums\s*=.*/Checksums = sha512/" {{{ aide_conf_path }}}
echo "Custom = sha256" >> {{{ aide_conf_path }}}
