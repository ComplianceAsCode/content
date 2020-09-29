#!/bin/bash
#

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chmod 0640 /etc/ssh/*_key
