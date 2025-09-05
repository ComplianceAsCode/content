#!/bin/bash
# variables = var_logind_session_timeout = 5_minutes

cat > /etc/systemd/logind.conf << EOM
[Login]
SomeOtherValue=123
StopIdleSessionSec=300
EOM
