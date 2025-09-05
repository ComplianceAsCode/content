#!/bin/bash
#

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX.pub)
chmod 0777 $FAKE_KEY
FAKE_KEY2=$(mktemp -p /etc/ssh/ XXXX.pub)
chmod 0644 $FAKE_KEY2
