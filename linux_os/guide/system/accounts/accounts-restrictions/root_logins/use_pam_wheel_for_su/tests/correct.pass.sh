#!/bin/bash

#clean possible commented lines
sed -i '/^.*auth.*required.*pam_wheel\.so.*use_uid$/d' /etc/pam.d/su

#apply correct line
echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su
