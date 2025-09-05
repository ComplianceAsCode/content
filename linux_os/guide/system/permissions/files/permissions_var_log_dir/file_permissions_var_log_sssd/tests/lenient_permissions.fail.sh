#!/bin/bash

mkdir -p /var/log/sssd
rm -rf /var/log/sssd/*

touch /var/log/sssd/testfile
chmod 777 /var/log/sssd/testfile
