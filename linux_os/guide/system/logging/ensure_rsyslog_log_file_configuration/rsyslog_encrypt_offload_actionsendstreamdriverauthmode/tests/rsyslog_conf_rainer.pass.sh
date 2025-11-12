#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_encrypt_offload_actionsendstreamdriverauthmode() }}}

echo 'action(type="omfwd" Target="some.example.com" StreamDriverAuthMode="x509/name")' >> "$RSYSLOG_CONF"
