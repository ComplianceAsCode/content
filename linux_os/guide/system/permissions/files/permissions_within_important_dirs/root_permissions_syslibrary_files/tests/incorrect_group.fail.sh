# platform = multi_platform_sle,Red Hat Enterprise Linux 8,multi_platform_fedora

for TESTFILE in /lib/test_me /lib64/test_me /usr/lib/test_me /usr/lib64/test_me
do
   if [[ ! -f $TESTFILE ]]
   then
     touch $TESTFILE
   fi
   chown nobody.nobody $TESTFILE
done
