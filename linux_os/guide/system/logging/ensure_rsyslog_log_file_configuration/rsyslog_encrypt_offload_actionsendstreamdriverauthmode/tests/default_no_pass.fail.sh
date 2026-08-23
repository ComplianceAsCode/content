#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdriverauthmode() }}}

if [[ -f $RSYSLOG_D_CONF ]]; then
  sed -i "/^\$ActionSendStreamDriverAuthMode.*/d" $RSYSLOG_D_CONF
fi
  sed -i "/^\$ActionSendStreamDriverAuthMode.*/d" $RSYSLOG_CONF
