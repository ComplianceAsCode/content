#!/bin/bash

if command -v yum; then
    yum remove -y aide
elif command -v apt-get; then
    DEBIAN_FRONTEND=noninteractive apt-get remove -y aide
fi

echo '21    21    *    *    *    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
