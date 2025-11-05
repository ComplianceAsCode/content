#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdrivermode() }}}

if [[ -f $RSYSLOG_D_CONF ]]; then
  sed -i i/\$ActionSendStreamDriverMod//g $RSYSLOG_D_CONF
fi
  sed -i i/\$ActionSendStreamDriverMod//g $RSYSLOG_CONF
