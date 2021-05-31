#!/bin/bash
  
for SYSCMDDIRS in  /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
do
   if [[ -d $SYSCMDDIRS ]]
   then
      find -L $SYSCMDDIRS ! -user root -type d -exec chown root '{}' \;
   fi
done
