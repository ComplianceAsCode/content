#!/bin/bash
# packages = passwd
# platform = multi_platform_all
# remediation = none

sed -i "s/^root:[^:]*/root:*/" /etc/shadow
