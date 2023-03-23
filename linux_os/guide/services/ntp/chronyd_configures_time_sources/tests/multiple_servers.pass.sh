#!/bin/bash
# packages = chrony


echo "" > {{{ chrony_conf_path }}}
echo "server 0.suse.pool.ntp.org" >> {{{ chrony_conf_path }}}
echo "server 1.suse.pool.ntp.org" >> {{{ chrony_conf_path }}}
echo "pool 2.suse.pool.ntp.org" >> {{{ chrony_conf_path }}}
echo "pool 3.suse.pool.ntp.org" >> {{{ chrony_conf_path }}}
