#!/bin/bash

for TESTDIR in /lib/test_dir /lib64/test_dir /usr/lib/test_dir /usr/lib64/test_dir
do
   if [[ ! -d $TESTDIR ]]
   then
     mkdir $TESTDIR
   fi
   chown nobody.nobody $TESTDIR
done
