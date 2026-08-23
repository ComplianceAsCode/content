#!/bin/bash

sed -i 's/.*umask.*/umask 077/g' /etc/init.d/functions
