#!/bin/bash
# variables = var_logind_session_timeout = 5_minutes

mkdir -p /etc/systemd
touch /etc/systemd/logind.conf

sed -i '/^.*StopIdleSessionSec.*$/d' /etc/systemd/logind.conf
