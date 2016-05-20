# platform = SUSE Enterprise 12
if [ $(getconf LONG_BIT) = "32" ] ; then 
   yum -y install kernel-PAE
fi
