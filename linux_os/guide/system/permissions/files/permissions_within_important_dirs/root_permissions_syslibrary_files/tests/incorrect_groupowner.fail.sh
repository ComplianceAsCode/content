# platform = multi_platform_sle,multi_platform_rhel,multi_platform_fedora,multi_platform_ubuntu

groupadd group_test
for TESTFILE in /lib/test_me /lib64/test_me /usr/lib/test_me /usr/lib64/test_me
do
   if [[ ! -f $TESTFILE ]]
   then
     touch $TESTFILE
   fi
   chgrp group_test $TESTFILE
done
