#!/bin/bash
# packages = rsyslog

{{{ setup_rsyslog_remote_loghost("# *.* @@192.168.122.1:5000") }}}
