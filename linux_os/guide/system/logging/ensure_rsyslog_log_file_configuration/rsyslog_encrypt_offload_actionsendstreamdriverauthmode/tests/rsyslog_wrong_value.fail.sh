#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdriverauthmode() }}}

echo "\$ActionSendStreamDriverAuthMode 0" >> $RSYSLOG_CONF
