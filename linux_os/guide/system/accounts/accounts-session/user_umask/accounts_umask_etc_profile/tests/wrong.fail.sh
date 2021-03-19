#!/bin/bash

sed -i '/umask/d' /etc/profile
echo "umask 000" >> /etc/profile
umask 000
