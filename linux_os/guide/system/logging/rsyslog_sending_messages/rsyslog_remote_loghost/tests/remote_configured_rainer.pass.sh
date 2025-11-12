#!/bin/bash
# packages = rsyslog

{{{ setup_rsyslog_remote_loghost('*.* action(type="omfwd" queue.type="linkedlist" queue.filename="example_fwd" action.resumeRetryCount="-1" queue.saveOnShutdown="on" target="192.168.122.1" port="30514" protocol="tcp")') }}}
