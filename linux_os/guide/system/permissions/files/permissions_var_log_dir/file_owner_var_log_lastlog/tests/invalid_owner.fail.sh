#!/bin/bash

username syslog || true

touch /var/log/lastlog.1
chown syslog /var/log/lastlog.1
