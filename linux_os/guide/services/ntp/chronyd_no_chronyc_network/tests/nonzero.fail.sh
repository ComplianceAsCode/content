#!/bin/bash
# packages = chrony
#

systemctl enable chronyd.service

echo "cmdport 324" >> {{{ chrony_conf_path }}}
