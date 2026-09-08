#!/bin/bash
# packages = chrony
# platform = Ubuntu 26.04

rm -rf /etc/chrony/conf.d
rm -rf /etc/chrony/sources.d

echo "server time.example.com" > {{{ chrony_conf_path }}}
