#!/bin/bash
# remediation = none

sed -E -i 's/(\w*:)(\$[^:]*)(:.*)/\1!!\3/' /etc/shadow
