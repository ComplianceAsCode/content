#!/bin/bash

pamFile="/etc/pam.d/system-auth"

# Make sure rounds is not set.
sed -iP --follow-symlinks "/password[[:space:]]\+sufficient[[:space:]]\+pam_unix\.so/ \
                                s/rounds=[[:digit:]]\+//" $pamFile
