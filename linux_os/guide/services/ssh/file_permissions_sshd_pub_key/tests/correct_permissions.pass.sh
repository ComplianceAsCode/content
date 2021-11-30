#!/bin/bash
#

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX.pub)
chmod 0644 /etc/ssh/*.pub
