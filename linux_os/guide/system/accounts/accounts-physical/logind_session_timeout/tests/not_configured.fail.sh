#!/bin/bash
# variables = var_logind_session_timeout = 5_minutes
source common.sh

mkdir -p /etc/systemd
touch "$LOGIND_CONF_FILE"

sed -i '/^.*StopIdleSessionSec.*$/d' "$LOGIND_CONF_FILE"
