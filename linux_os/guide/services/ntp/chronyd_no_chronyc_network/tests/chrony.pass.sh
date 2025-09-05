#!/bin/bash
# packages = chrony
#

systemctl enable chronyd.service

echo "cmdport 0" >> {{{ chrony_conf_path }}}
