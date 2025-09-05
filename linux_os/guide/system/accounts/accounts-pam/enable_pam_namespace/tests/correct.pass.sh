#!/bin/bash

if ! grep -Eq '^\s*session\s+required\s+pam_namespace.so\s*$' '/etc/pam.d/login' ; then
    echo "session    required     pam_namespace.so" >> "/etc/pam.d/login"
fi