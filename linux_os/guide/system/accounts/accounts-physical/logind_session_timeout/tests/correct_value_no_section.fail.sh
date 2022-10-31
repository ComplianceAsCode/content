#!/bin/bash
# variables = var_logind_session_timeout = 5_minutes

echo "StopIdleSessionSec=300" > /etc/systemd/logind.conf
