#!/bin/bash
#

sed -i 's/^\([^:]*\):x:/\1:\*:/' /etc/passwd
