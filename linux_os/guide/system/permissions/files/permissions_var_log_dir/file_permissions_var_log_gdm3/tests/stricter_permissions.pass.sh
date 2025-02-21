#!/bin/bash

mkdir -p /var/log/gdm3
chmod -R 0 /var/log/gdm3/*

touch /var/log/gdm3/testfile
chmod 400 /var/log/gdm3/testfile
