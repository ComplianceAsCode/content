#!/bin/bash

echo "auth  sufficient  pam_unix.so try_first_pass nullok" >> /etc/pam.d/system-auth
