#!/bin/bash

cp $SHARED/fstab /etc/
sed -i 's/,sec=krb5:krb5i:krb5p//' /etc/fstab
