#!/bin/bash

mkdir -p /var/log/gdm
chmod -R 0 /var/log/gdm/*

touch /var/log/gdm/testfile
chmod 777 /var/log/gdm/testfile
