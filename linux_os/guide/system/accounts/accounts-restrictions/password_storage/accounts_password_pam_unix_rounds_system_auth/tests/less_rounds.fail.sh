#!/bin/bash

pamFile="/etc/pam.d/system-auth"

# Make sure rounds is set to value less than default value
if grep -q "rounds=" $pamFile; then
    sed -iP --follow-symlinks "/password[[:space:]]\+sufficient[[:space:]]\+pam_unix\.so/ \
                                    s/rounds=[[:digit:]]\+/rounds=2000/" $pamFile
else
    sed -iP --follow-symlinks "/password[[:space:]]\+sufficient[[:space:]]\+pam_unix\.so/ s/$/ rounds=2000/" $pamFile
fi
