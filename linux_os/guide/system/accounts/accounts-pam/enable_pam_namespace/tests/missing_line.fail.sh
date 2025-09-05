#!/bin/bash

sed -i -E '/^\s*session\s+required\s+pam_namespace.so\s*$/d' /etc/pam.d/login
