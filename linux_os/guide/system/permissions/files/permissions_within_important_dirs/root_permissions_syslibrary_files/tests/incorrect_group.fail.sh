#!/bin/bash

# There is a high probability that there will be nested subdirectories within the
# shared system library directories, therefore we should test to make sure we
# cover this. - cmm
test -d /usr/lib/test_dir || mkdir -p /usr/lib/test_dir && chown nobody.nobody /usr/lib/test_dir
for TESTFILE in /lib/test_me /lib64/test_me /usr/lib/test_me /usr/lib64/test_me /usr/lib/test_dir/test_me
do
   if [[ ! -f $TESTFILE ]]
   then
     touch $TESTFILE
   fi
   chown nobody.nobody $TESTFILE
done
