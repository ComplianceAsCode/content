#!/bin/bash
# variables = var_logind_session_timeout = 5_minutes

cat > /etc/systemd/logind.conf << EOM
[Logind]
StopIdleSessionSec=300
EOM
