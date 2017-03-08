# platform = multi_platform_rhel, multi_platform_fedora
for LIBDIR in /usr/lib /usr/lib64 /lib /lib64
do
  if [ -d $LIBDIR ]
  then
    find -L $LIBDIR \! -user root -exec chown root {} \; 
  fi
done
