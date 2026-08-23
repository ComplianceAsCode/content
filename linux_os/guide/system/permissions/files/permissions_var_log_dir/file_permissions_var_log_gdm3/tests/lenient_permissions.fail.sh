#!/bin/bash

mkdir -p /var/log/gdm3
chmod -R 0 /var/log/gdm3/*

touch /var/log/gdm3/testfile
chmod 777 /var/log/gdm3/testfile
