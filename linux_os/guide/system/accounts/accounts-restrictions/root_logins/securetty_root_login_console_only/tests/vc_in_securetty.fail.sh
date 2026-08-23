#!/bin/bash
#

if grep -q "^vc" /etc/securetty; then
	sed -i "s;^vc.*;vc/20;" /etc/securetty
else
	echo "vc/2" >> /etc/securetty
fi
