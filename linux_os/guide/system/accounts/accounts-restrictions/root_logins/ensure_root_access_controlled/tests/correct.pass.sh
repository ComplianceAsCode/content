#!/bin/bash
# packages = passwd
# platform = multi_platform_all

sed -i "s/^root:[^:]*/root:\$y\$AAAAAAAAAA/" /etc/shadow
