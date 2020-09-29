#!/bin/bash

echo '@weekly    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
