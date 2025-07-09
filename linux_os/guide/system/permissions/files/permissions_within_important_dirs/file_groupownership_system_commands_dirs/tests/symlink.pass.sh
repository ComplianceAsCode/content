#!/bin/bash

groupadd group_test

find -P /bin/ /sbin/ /usr/bin/ /usr/sbin/ /usr/local/bin/ /usr/local/sbin/ \! -group root -type f -exec chgrp -P root {} \;

ln -s $(mktemp -p /tmp) /usr/bin/test.log.symlink
chgrp -h group_test /usr/bin/test.log.symlink
