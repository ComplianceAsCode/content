#!/bin/bash
# platform = multi_platform_ubuntu

sed -i "s/^root:[^:]*/root:\$y\$AAAAAAAAAA/" /etc/shadow
