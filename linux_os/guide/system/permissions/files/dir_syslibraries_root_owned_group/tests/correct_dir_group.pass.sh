#!/bin/bash

for SYSLIBDIRS in /lib /lib64 /usr/lib /usr/lib64
do
    find $SYSLIBDIRS ! -group root -type d -exec chgrp root '{}' \;
done
