#!/bin/bash
# packages = ufw

ufw allow ssh
ufw default reject outgoing
ufw -f enable
