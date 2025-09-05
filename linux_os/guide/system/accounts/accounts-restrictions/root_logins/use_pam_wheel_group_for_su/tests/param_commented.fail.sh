#!/bin/bash
# variables = var_pam_wheel_group_for_su=sugroup

# remove any remaining uncommented pam_wheel.so line
sed -Ei '/^auth\b.*\brequired\b.*\bpam_wheel\.so/d' /etc/pam.d/su

#apply line with commented parameters
echo "auth required pam_wheel.so #use_uid group=sugroup" >> /etc/pam.d/su
