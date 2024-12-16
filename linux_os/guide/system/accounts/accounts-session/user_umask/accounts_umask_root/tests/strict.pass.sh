#!/bin/bash

sed '/umask/d' -i /root/.bashrc /root/.profile
echo "umask 0777" >> /root/.profile
