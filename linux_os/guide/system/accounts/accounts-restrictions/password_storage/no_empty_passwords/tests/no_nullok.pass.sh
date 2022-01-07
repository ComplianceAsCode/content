#!/bin/bash

sed -i --follow-symlinks '/nullok/d' /etc/pam.d/system-auth
