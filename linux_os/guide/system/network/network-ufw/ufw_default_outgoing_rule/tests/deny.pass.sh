#!/bin/bash
# packages = ufw

ufw allow ssh
ufw default deny outgoing
ufw -f enable
