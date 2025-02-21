#!/bin/bash

username syslog || true

touch /var/log/lastlog
chown syslog /var/log/lastlog
