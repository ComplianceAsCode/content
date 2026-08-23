#!/bin/bash
# packages = ufw

ufw allow ssh
ufw default allow incoming
ufw -f enable
