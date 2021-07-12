#!/bin/bash

for LIBDIR in /usr/lib/ /usr/lib64/ /lib/ /lib64/ /lib/modules
do
  if [ -d $LIBDIR/testfile ]
    touch $LIBDIR/testfile
  then
    chgrp nobody $LIBDIR/testfile
  fi
done
