#!/bin/bash
# remediation = none

# remove any non-system user
sed -Ei '/^root|nologin$|halt$|sync$|shutdown$/!d' /etc/passwd
