#!/bin/bash

source common.sh

echo -e "[pam]\noffline_credentials_expiration = 1" >> $SSSD_CONF
