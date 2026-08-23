#!/bin/bash
# packages = ufw

ufw allow ssh
ufw default reject incoming
ufw -f enable
