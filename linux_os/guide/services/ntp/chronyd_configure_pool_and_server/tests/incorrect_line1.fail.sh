#!/bin/bash
# packages = chrony


echo "" > {{{ chrony_conf_path }}}
echo "server0.suse.pool.ntp.org" >> {{{ chrony_conf_path }}}
echo "pool1.suse.pool.ntp.org" >> {{{ chrony_conf_path }}}
