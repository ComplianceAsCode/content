#!/bin/bash
#

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chmod 0777 $FAKE_KEY
FAKE_KEY2=$(mktemp -p /etc/ssh/ XXXX_key)
chmod 0640 $FAKE_KEY2
