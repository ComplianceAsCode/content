#!/bin/bash
# packages = rsyslog

{{{ setup_rsyslog_remote_loghost('*.* action(type="omfwd"\nqueue.type="linkedlist"\nqueue.filename="example_fwd"\naction.resumeRetryCount="-1"\nqueue.saveOnShutdown="on"\ntarget="192.168.122.1"\nport="30514"\nprotocol="tcp")') }}}
