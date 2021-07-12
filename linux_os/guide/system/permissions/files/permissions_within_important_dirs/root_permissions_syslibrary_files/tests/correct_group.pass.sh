#!/bin/bash

for SYSLIBDIRS in /lib /lib64 /usr/lib /usr/lib64
do
    if [[ -d $SYSLIBDIRS  ]]
    then
        find $SYSLIBDIRS ! -group root -exec chgrp root '{}' \;
    fi
done
