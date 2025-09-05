#!/bin/bash


if grep -Eq '^\s*session\s+required\s+pam_namespace.so\s*$' '/etc/pam.d/login' ; then
    sed -i -E 's/^\s*session\s+required\s+pam_namespace.so\s*$/# session    required     pam_namespace.so/' /etc/pam.d/login
else
    echo "# session    required     pam_namespace.so" >> "/etc/pam.d/login"
fi

