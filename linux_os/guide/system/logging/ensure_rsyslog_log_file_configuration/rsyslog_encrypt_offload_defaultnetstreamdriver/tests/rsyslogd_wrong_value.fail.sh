#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_defaultnetstreamdriver() }}}

echo "\$DefaultNetstreamDriver none" >> $RSYSLOG_D_CONF
