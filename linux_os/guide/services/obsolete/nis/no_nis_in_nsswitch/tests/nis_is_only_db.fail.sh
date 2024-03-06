#! /bin/bash

# we use something because if passwd or groups is used, it breaks the system
echo "something nis" > /etc/nsswitch.conf
echo "group files" >> /etc/nsswitch.conf
