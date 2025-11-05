#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdriverauthmode() }}}

if [[ -f $RSYSLOG_D_CONF ]]; then
  sed -i "/^\$ActionSendStreamDriverMod.*/d" $RSYSLOG_D_CONF
fi
  sed -i "/^\$ActionSendStreamDriverMod.*/d" $RSYSLOG_CONF
