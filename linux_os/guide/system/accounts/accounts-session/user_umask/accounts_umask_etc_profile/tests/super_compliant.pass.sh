#!/bin/bash

sed -i '/umask/d' /etc/profile
echo "umask 777" >> /etc/profile
umask 777
