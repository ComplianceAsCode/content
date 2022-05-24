#!/bin/bash

source common.sh

echo -e "[pam]\n#offline_credentials_expiration = 1" >> $SSSD_CONF

echo -e "[domain/EXAMPLE]\ncache_credentials = true" >> $SSSD_CONF
