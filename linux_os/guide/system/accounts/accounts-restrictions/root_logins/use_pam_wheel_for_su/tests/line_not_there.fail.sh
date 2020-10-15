#!/bin/bash

#clean possible lines
sed -i '/^.*auth.*required.*pam_wheel\.so.*use_uid$/d' /etc/pam.d/su
