#!/bin/bash

#clean possible commented lines
sed -i '/^.*auth.*required.*pam_wheel\.so.*use_uid/d' /etc/pam.d/su

#apply correct line with additional options for pam_wheel.so
echo "auth required pam_wheel.so use_uid group=sugroup" >> /etc/pam.d/su
