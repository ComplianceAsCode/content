#!/bin/bash

sed '/umask/d' -i /root/.bashrc /root/.profile || true
echo "umask 0027" >> /root/.bashrc
