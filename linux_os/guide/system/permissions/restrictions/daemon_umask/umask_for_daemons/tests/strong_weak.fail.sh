#!/bin/bash

sed -i 's/.*umask.*/umask 007/g' /etc/init.d/functions
