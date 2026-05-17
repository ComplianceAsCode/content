#!/bin/bash
# platform = SUSE Linux Enterprise 15, SUSE Linux Enterprise 16

echo "auth	optional 	pam_unix.so	try_first_pass sha512" > /etc/pam.d/common-auth
