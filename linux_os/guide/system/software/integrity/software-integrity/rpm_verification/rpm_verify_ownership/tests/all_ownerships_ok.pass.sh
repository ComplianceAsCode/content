#!/bin/bash

# Perform same steps as remediation
declare -A SETOWNER_RPM_LIST
FILES_WITH_INCORRECT_OWNERSHIP=($(rpm -Va --nofiledigest | awk '{ if (substr($0,6,1)=="U" || substr($0,7,1)=="G") print $NF }'))

for FILE_PATH in "${FILES_WITH_INCORRECT_OWNERSHIP[@]}"; do
    RPM_PACKAGES=$(rpm -qf "$FILE_PATH")
    for pkg in $RPM_PACKAGES; do
        SETOWNER_RPM_LIST["$pkg"]=1
    done
done

for RPM_PACKAGE in "${!SETOWNER_RPM_LIST[@]}"; do
    rpm --setugids "${RPM_PACKAGE}"
done
