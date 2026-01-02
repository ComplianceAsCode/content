#!/bin/bash
# variables = var_logind_session_timeout = 5_minutes
source common.sh

cat > "$LOGIND_CONF_FILE" << EOM
[Login]
StopIdleSessionSec=310
EOM
