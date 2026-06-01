#!/bin/bash

groupadd group_test

{{% if 'ol9' in product %}}
find -P /bin/ /sbin/ /usr/bin/ /usr/sbin/ /usr/libexec/ /usr/local/bin/ /usr/local/sbin/ -type f -exec chgrp --no-dereference root {} \; || true
{{% else %}}
find -P /bin/ /sbin/ /usr/bin/ /usr/sbin/ /usr/local/bin/ /usr/local/sbin/ -type f -exec chgrp --no-dereference root {} \; || true
{{% endif %}}

{{% if 'ubuntu' in product %}}
for TESTFILE in /bin/test_me /sbin/test_me /usr/bin/test_me /usr/sbin/test_me /usr/local/bin/test_me /usr/local/sbin/test_me
{{% else %}}
{{% if 'ol9' in product %}}
for TESTFILE in /bin/test_me /sbin/test_me /usr/bin/test_me /usr/libexec/test_me /usr/sbin/test_me /usr/local/bin/test_me
{{% else %}}
for TESTFILE in /bin/test_me /sbin/test_me /usr/bin/test_me /usr/sbin/test_me /usr/local/bin/test_me
{{% endif %}}
{{% endif %}}
do
  if [[ ! -f $TESTFILE ]]
  then
    touch $TESTFILE
  fi
  chmod u+x $TESTFILE
  chgrp group_test $TESTFILE
done
