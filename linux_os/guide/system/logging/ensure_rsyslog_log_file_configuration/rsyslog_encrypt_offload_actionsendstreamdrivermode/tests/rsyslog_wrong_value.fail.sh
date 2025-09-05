#!/bin/bash
bash -x setup.sh

echo "\$ActionSendStreamDriverMode 0" >> /etc/rsyslog.d/encrypt.conf
