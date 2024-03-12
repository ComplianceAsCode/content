#!/bin/bash
# packages = aide,crontabs

{{{ bash_package_remove("aide") }}}

echo '21    21    *    *    *    root    {{{ aide_bin_path }}} --check &>/dev/null' >> /etc/crontab
