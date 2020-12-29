#!/bin/bash
#

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chmod 0777 $FAKE_KEY
