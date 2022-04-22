#!/bin/bash

# make sure umask commented out in /etc/profile
sed -i '/umask/d' /etc/profile
echo "#umask 777" >> /etc/profile
umask 000
