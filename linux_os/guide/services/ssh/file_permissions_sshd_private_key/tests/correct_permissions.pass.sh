#!/bin/bash
#

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chmod 0600 /etc/ssh/*_key
