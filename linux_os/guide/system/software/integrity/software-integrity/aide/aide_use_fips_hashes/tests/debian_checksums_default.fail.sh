#!/bin/bash
# packages = aide
# platform = multi_platform_debian,multi_platform_ubuntu

sed -i "s/^Checksums\s*=.*/Checksums = H/" {{{ aide_conf_path }}}
