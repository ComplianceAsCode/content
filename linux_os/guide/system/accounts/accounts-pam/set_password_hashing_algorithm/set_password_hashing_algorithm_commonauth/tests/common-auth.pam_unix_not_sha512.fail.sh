#!/bin/bash
# platform = SUSE Linux Enterprise 15, SUSE Linux Enterprise 16

echo "auth	sufficient 	pam_unix.so	try_first_pass" > /etc/pam.d/common-auth
