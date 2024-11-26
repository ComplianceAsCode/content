#!/bin/bash
# packages = chrony
# variables = var_multiple_time_servers=0.suse.pool.ntp.org,1.suse.pool.ntp.org,2.suse.pool.ntp.org,3.suse.pool.ntp.org
# variables = var_multiple_time_pools=0.suse.pool.ntp.org,1.suse.pool.ntp.org,2.suse.pool.ntp.org,3.suse.pool.ntp.org

rm -f {{{ chrony_conf_path }}}
