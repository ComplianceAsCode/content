#!/bin/bash
#

# Declare an associative array to hold list of RPM packages we need to correct permissions for
declare -A SETPERMS_RPM_LIST

# Create a list of files on the system having permissions different from what
# is expected by the RPM database
FILES_WITH_INCORRECT_PERMS=($(rpm -Va --nofiledigest | awk '{ if (substr($0,2,1)=="M") print $NF }'))

# For each file path from that list:
# * Determine the RPM package the file path is shipped by,
# * Include it into SETPERMS_RPM_LIST array

for FILE_PATH in "${FILES_WITH_INCORRECT_PERMS[@]}"
do
	RPM_PACKAGE=$(rpm -qf "$FILE_PATH")
	SETPERMS_RPM_LIST["$RPM_PACKAGE"]=1
done

# For each of the RPM packages left in the list -- reset its permissions to the
# correct values
for RPM_PACKAGE in "${!SETPERMS_RPM_LIST[@]}"
do
	rpm --setperms "${RPM_PACKAGE}"
done

