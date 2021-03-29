#!/bin/bash

sed -i '/umask/d' /etc/bashrc
echo "umask 777" >> /etc/bashrc
umask 777
