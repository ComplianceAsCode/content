#!/bin/bash

sed '/umask/d' -i /root/.bashrc /root/.profile || true
echo "umask 0000" >> /root/.bashrc
echo "umask 0027" >> /root/.profile
