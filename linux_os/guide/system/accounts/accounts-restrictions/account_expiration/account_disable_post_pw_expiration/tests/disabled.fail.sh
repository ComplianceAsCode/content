#!/bin/bash

if grep -q "^INACTIVE" /etc/default/useradd; then
	sed -i "s/^INACTIVE.*/INACTIVE=-1/" /etc/default/useradd
else
	echo "INACTIVE=-1" >> /etc/default/useradd
fi
