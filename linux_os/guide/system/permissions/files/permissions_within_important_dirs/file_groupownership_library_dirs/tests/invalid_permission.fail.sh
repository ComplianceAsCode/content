#!/bin/bash

for TESTFILE in /lib/testfile /lib64/testfile /usr/lib/testfile /usr/lib64/testfile /lib/modules/testfile
do
   if [[ ! -f $TESTFILE ]]
   then
     touch $TESTFILE
   fi
   chgrp nobody $TESTFILE
done
