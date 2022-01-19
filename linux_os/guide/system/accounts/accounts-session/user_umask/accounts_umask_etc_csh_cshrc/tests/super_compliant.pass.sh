#!/bin/bash

sed -i '/umask/d' /etc/csh.cshrc
echo "umask 777" >> /etc/csh.cshrc
umask 777
