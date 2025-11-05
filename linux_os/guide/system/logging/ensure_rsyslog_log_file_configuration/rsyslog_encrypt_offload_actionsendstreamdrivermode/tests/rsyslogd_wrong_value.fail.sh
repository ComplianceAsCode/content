#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdrivermode() }}}

echo "\$ActionSendStreamDriverMode 0" >> $RSYSLOG_D_CONF
