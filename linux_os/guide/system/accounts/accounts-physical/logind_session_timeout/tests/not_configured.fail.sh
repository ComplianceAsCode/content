#!/bin/bash
# variables = var_logind_session_timeout = 5_minutes

sed -i '/^.*StopIdleSessionSec.*$/d' /etc/systemd/logind.conf
