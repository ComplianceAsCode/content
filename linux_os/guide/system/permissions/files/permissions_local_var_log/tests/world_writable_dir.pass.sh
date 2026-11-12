#!/bin/bash

find /var/log -type f -exec chmod 640 {} +
mkdir -p /var/log/testme
chmod 777 /var/log/testme
