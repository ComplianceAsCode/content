# platform = multi_platform_rhel,multi_platform_ol,multi_platform_rhv
# reboot = false
# strategy = restrict
# complexity = high
# disruption = medium

# Declare array to hold set of RPM packages we need to correct permissions for
declare -A SETPERMS_RPM_DICT

# Create a list of files on the system having permissions different from what
# is expected by the RPM database
readarray -t FILES_WITH_INCORRECT_PERMS < <(rpm -Va --nofiledigest | awk '{ if (substr($0,6,1)=="U" || substr($0,7,1)=="G") print $NF }')

for FILE_PATH in "${FILES_WITH_INCORRECT_PERMS[@]}"
do
        RPM_PACKAGE=$(rpm -qf "$FILE_PATH")
	# Use an associative array to store packages as it's keys, not having to care about duplicates.
	SETPERMS_RPM_DICT["$RPM_PACKAGE"]=1
done

# For each of the RPM packages left in the list -- reset its permissions to the
# correct values
for RPM_PACKAGE in "${!SETPERMS_RPM_DICT[@]}"
do
        rpm --setugids "${RPM_PACKAGE}"
done
