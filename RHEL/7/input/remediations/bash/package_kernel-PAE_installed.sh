# platform = Red Hat Enterprise Linux 7
if [ $(getconf LONG_BIT) = "32" ] ; then 
   yum -y install kernel-PAE
fi
