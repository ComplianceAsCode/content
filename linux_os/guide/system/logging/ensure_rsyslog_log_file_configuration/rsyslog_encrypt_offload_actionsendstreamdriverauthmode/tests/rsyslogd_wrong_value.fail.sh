#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdriverauthmode() }}}

echo "\$ActionSendStreamDriverAuthMode x509/certvalid" >> $RSYSLOG_D_CONF
