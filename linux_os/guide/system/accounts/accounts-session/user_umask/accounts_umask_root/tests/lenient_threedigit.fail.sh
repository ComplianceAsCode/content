#!/bin/bash

sed '/umask/d' -i /root/.bashrc /root/.profile
echo "umask 022" >> /root/.profile
