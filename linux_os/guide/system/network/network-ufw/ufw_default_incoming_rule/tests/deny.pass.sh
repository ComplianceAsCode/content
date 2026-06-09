#!/bin/bash
# packages = ufw

ufw allow ssh
ufw default deny incoming
ufw -f enable
