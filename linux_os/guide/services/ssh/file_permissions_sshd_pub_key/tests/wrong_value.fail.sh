#!/bin/bash
#

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX.pub)
chmod 0777 $FAKE_KEY
