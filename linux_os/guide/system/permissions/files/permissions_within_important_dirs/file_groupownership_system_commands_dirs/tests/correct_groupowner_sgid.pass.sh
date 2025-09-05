#!/bin/bash
# platform = multi_platform_ubuntu

find -P /bin/ /sbin/ /usr/bin/ /usr/sbin/ /usr/local/bin/ /usr/local/sbin/ -type f -exec chgrp --no-dereference root {} \; || true

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
  chgrp root $TESTFILE
  chmod g+s $TESTFILE
done
