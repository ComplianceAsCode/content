#!/bin/bash

sed -i 's/.*umask.*/umask 022/g' /etc/init.d/functions
