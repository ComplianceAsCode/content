#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_defaultnetstreamdriver() }}}

echo "\$DefaultNetstreamDriver gtls" >> $RSYSLOG_CONF
