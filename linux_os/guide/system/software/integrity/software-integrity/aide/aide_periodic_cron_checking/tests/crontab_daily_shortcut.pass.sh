#!/bin/bash

echo '@daily    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
