#!/bin/bash

# Fail GRUB_DISABLE_RECOVERY
# if GRUB_DISABLE_RECOVERY=true, set to false
# if not set, do nothing, since that is also a failure.
if grep -q '^GRUB_DISABLE_RECOVERY=.*'  '/etc/default/grub' ; then
       # modify the GRUB command-line if an GRUB_DISABLE_RECOVERY= arg already exists
       sed -i 's/GRUB_DISABLE_RECOVERY=.*/GRUB_DISABLE_RECOVERY=false/' /etc/default/grub
fi

