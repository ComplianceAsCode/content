#!/bin/bash

# gid of sshd group is 74
test_group="sshd"

for TESTFILE in /bin/test_me /sbin/test_me /usr/bin/test_me /usr/sbin/test_me /usr/local/bin/test_me /usr/local/sbin/test_me
do
   if [[ ! -f $TESTFILE ]]
   then
     touch $TESTFILE
   fi
   chgrp "$test_group" $TESTFILE
done
