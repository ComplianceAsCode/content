#!/bin/bash
#

sed -i 's/^\([^:]*\):\*:/\1:x:/' /etc/passwd
