#!/bin/bash
# platform = multi_platform_ubuntu

{{% if 'ubuntu' in product %}}
useradd crontab
for SYSLIBDIRS in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
{{% else %}}
for SYSLIBDIRS in /bin /sbin /usr/bin /usr/sbin /usr/local/bin
{{% endif %}}
do
  find -L  $SYSLIBDIRS \! -group root -type f -exec chgrp root '{}' \;
done

groupadd group_test

{{% if 'ubuntu' in product %}}
for TESTFILE in /bin/test_me /sbin/test_me /usr/bin/test_me /usr/sbin/test_me /usr/local/bin/test_me /usr/local/sbin/test_me
{{% else %}}
for TESTFILE in /bin/test_me /sbin/test_me /usr/bin/test_me /usr/sbin/test_me /usr/local/bin/test_me
{{% endif %}}
do
  if [[ ! -f $TESTFILE ]]
  then
    touch $TESTFILE
  fi
  chgrp group_test $TESTFILE
  chmod g-s $TESTFILE
done
