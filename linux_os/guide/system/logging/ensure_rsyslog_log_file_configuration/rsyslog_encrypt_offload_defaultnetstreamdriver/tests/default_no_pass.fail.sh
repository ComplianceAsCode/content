#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_defaultnetstreamdriver() }}}

if [[ -f RSYSLOG_D_CONF ]]; then
  sed -i i/\$DefaultNetstreamDriver*.$//g $RSYSLOG_D_CONF
fi
  sed -i i/\$DefaultNetstreamDriver*.$//g $RSYSLOG_CONF
