#!/bin/bash
  
for TESTDIR in /bin/test_1 /sbin/test_1 /usr/bin/test_1 /usr/sbin/test_1 /usr/local/bin/test_1 /usr/local/sbin/test_1
do
   if [[ ! -d $TESTDIR ]]
   then
     mkdir $TESTDIR
   fi
   chown nobody.nobody $TESTDIR
done
