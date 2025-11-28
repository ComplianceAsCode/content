#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdriverauthmode() }}}

echo "\$ActionSendStreamDriverAuthMode x509/name" >> $RSYSLOG_CONF
