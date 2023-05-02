#!/bin/bash

# remove all interactive users (ID >= 1000) from /etc/passwd
sed -i '/.*:[0-9]\{4,\}:/d' /etc/passwd
