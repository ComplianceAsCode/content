#!/bin/bash
# platform = multi_platform_ol

sed -i -E '/password\s+substack\s+system-auth/d' /etc/pam.d/passwd
