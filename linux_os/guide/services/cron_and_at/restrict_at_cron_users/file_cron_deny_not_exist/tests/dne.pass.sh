#!/bin/bash

FILE=/etc/cron.deny

if [ -f $FILE ]; then
	rm $FILE
fi
