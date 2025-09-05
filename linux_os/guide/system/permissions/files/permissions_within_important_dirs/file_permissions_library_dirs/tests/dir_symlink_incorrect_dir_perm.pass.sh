#!/bin/bash

useradd user_test
TESTDIR="/usr/lib/"

# Ensure everything is all right
chmod -R u-s,g-ws,o-wt /lib /lib64 /usr/lib /usr/lib64

# Let's setup a symlink to a directory,whose permissions are incompliant

# Directory with incorrect perms
mkdir /home/user_test/directory
chmod 0766 /home/user_test/directory

# File with correct perms
touch /home/user_test/directory/test_file
chmod 0755 /home/user_test/directory/test_file

ln -s /home/user_test $TESTDIR/user_test_home
