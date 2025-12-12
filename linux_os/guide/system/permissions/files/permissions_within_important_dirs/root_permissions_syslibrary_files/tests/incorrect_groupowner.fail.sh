#!/bin/bash
# platform = multi_platform_sle,multi_platform_rhel,multi_platform_fedora,multi_platform_ubuntu,multi_platform_ol

groupadd group_test
{{% if 'ol' in families or 'rhel' in product %}}
for TESTFILE in /lib/test_me.so /lib64/test_me.so /usr/lib/test_me.so /usr/lib64/test_me.so
{{% else %}}
for TESTFILE in /lib/test_me /lib64/test_me /usr/lib/test_me /usr/lib64/test_me
{{% endif %}}
do
   if [[ ! -f $TESTFILE ]]
   then
     touch $TESTFILE
   fi
   chgrp group_test $TESTFILE
done
