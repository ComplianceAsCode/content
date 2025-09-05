#!/bin/bash
# platform = multi_platform_ubuntu

for SYSLIBDIRS in /lib /lib64 /usr/lib /usr/lib64
do
    if [[ -d $SYSLIBDIRS  ]]
    then
        find $SYSLIBDIRS ! -group root -type f -exec chgrp root '{}' \;
    fi
done

groupadd -r cac_sys
touch /lib/test_me

chgrp cac_sys /lib/test_me
