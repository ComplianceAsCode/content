#!/bin/bash


AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
  sed -i '/^.*remember.*$/d' $pamFile
done
