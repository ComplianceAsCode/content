#!/bin/bash
# packages = crontabs

FILE=/etc/cron.deny

if [ -f $FILE ]; then
	rm $FILE
fi
