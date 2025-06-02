#!/bin/bash
{{% if product in ["ubuntu2404"] %}}
test_group="_ssh"
{{% else %}}
test_group="root"
{{% endif %}}

for TESTFILE in /bin/test_me /sbin/test_me /usr/bin/test_me /usr/sbin/test_me /usr/local/bin/test_me
do
  if [[ ! -f $TESTFILE ]]
  then
    touch $TESTFILE
  fi
  chgrp "$test_group" $TESTFILE
done
