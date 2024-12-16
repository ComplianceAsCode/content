#!/bin/bash

sed '/umask/d' -i /root/.bashrc /root/.profile
echo "umask 0027" >> /root/.bashrc
