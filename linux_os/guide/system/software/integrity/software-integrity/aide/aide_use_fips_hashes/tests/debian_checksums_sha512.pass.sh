#!/bin/bash
# packages = aide
# platform = multi_platform_debian

sed -i "s/^Checksums\s*=.*/Checksums = sha512/" {{{ aide_conf_path }}}
