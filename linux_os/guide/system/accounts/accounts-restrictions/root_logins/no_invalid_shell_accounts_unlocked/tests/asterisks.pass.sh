#!/bin/bash
# remediation = none

sed -i 's/^\([^:]*\):x:/\1:\*:/' /etc/passwd
