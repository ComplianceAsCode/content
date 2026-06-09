#!/bin/bash
# packages = ufw

ufw allow ssh
ufw default allow outgoing
ufw -f enable
