#!/bin/bash

COREDUMP_PATH=/etc/systemd/coredump.conf

if [ ! -f $COREDUMP_PATH ]; then
    echo "[Coredump]" >> $COREDUMP_PATH
fi
