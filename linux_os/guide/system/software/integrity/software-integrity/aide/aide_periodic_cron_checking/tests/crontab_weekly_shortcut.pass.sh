#!/bin/bash
# packages = aide,crontabs

echo '@weekly    root    {{{ aide_bin_path }}} --check &>/dev/null' >> /etc/crontab
