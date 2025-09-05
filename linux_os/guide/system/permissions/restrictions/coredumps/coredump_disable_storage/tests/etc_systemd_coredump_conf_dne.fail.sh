#!/bin/bash
FILE="/etc/systemd/coredump.conf"
if [ -f $FILE ]; then
    rm $FILE
fi

