#!/bin/bash

useradd user_test
TESTDIR="/usr/lib/"

# Ensure everything is all right
chmod -R u-s,g-ws,o-wt /lib /lib64 /usr/lib /usr/lib64

# Let's setup a symlink to a file, whose permissions are incompliant

# File with incorrect perms
touch /home/user_test/test_file
chmod 0766 /home/user_test/test_file

ln -s /home/user_test/test_file $TESTDIR/user_test_home
