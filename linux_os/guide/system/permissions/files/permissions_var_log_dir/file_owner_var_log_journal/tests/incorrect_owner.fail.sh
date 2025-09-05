#!/bin/bash

chown -R root /var/log

mkdir -p /var/log/journal
touch /var/log/journal/my.journal
chown nobody /var/log/journal/my.journal
