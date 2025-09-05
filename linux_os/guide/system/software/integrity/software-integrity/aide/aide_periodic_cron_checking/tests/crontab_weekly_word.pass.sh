#!/bin/bash
# packages = aide,crontabs

echo '21    21    *    *    mon    root    {{{ aide_bin_path }}} --check &>/dev/null' >> /etc/crontab
