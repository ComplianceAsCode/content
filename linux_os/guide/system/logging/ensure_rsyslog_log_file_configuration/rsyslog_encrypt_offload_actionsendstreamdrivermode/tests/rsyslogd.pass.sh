#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdrivermode() }}}

echo "\$ActionSendStreamDriverMode 1" >> $RSYSLOG_D_CONF
