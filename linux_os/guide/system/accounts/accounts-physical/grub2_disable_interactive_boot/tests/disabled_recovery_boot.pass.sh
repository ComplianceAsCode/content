#!/bin/bash

# make sure GRUB_DISABLE_RECOVERY=true
if grep -q '^GRUB_DISABLE_RECOVERY=.*'  '/etc/default/grub' ; then
       # modify the GRUB command-line if an GRUB_DISABLE_RECOVERY= arg already exists
       sed -i 's/GRUB_DISABLE_RECOVERY=.*/GRUB_DISABLE_RECOVERY=true/' /etc/default/grub
else
       # no GRUB_DISABLE_RECOVERY=arg is present, append it to file
       echo "GRUB_DISABLE_RECOVERY=true"  >> '/etc/default/grub'
fi
