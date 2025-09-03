#!/bin/bash
# packages = chrony
# variables = var_multiple_time_servers=time.nist.gov,time-a-g.nist.gov,time-b-g.nist.gov,time-c-g.nist.gov,var_multiple_time_pools=time.nist.gov

echo "" > {{{ chrony_conf_path }}}
echo "server time.nist.gov" >> {{{ chrony_conf_path }}}
echo "server time-a-g.nist.gov" >> {{{ chrony_conf_path }}}
echo "pool time.nist.gov" >> {{{ chrony_conf_path }}}
