#!/bin/bash
# platform = Ubuntu 24.04

groupadd group_test

find -P /bin/ /sbin/ /usr/bin/ /usr/sbin/ /usr/local/bin/ /usr/local/sbin/ \! -group root -type f -exec chgrp --no-dereference root {} \; || true

for TESTFILE in /bin/test_me /sbin/test_me /usr/bin/test_me /usr/sbin/test_me /usr/local/bin/test_me /usr/local/sbin/test_me
do
  if [[ ! -f $TESTFILE ]]
  then
    touch $TESTFILE
  fi
  chgrp group_test $TESTFILE
  chmod u-x $TESTFILE
done
