#!/bin/bash
# packages = chrony
# variables = var_multiple_time_servers=0.debian.pool.ntp.org,1.debian.pool.ntp.org,2.debian.pool.ntp.org,3.debian.pool.ntp.org,var_multiple_time_pools=0.debian.pool.ntp.org,1.debian.pool.ntp.org,2.debian.pool.ntp.org,3.debian.pool.ntp.org

echo "" > {{{ chrony_conf_path }}}
echo "pool 2.debian.pool.ntp.org iburst" >> {{{ chrony_conf_path }}}
