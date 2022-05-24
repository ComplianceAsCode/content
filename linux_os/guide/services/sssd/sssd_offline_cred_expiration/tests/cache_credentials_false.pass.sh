#!/bin/bash

# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
source common.sh

echo -e "[pam]\noffline_credentials_expiration = 2" >> $SSSD_CONF

echo -e "[domain/EXAMPLE]\ncache_credentials = false" >> $SSSD_CONF
