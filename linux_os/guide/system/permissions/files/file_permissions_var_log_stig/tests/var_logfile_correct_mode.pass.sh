#!/bin/bash

chmod -R 640 /var/log
mkdir -p /var/log/testme
touch /var/log/testme/test.log
chmod 640 /var/log/testme/test.log
