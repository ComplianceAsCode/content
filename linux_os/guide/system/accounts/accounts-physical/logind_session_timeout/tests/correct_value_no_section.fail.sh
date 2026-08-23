#!/bin/bash
# variables = var_logind_session_timeout = 5_minutes
source common.sh

echo "StopIdleSessionSec=300" > "$LOGIND_CONF_FILE"
