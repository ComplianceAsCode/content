#!/bin/bash
# packages = aide,crontabs

echo '@daily    root    {{{ aide_bin_path }}} --check &>/dev/null' >> /etc/crontab
