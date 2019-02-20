# platform = multi_platform_rhel,multi_platform_ol,multi_platform_rhv
# reboot = false
# strategy = restrict
# complexity = high
# disruption = medium

# Declare array to hold list of RPM packages we need to correct permissions for
SETPERMS_RPM_LIST=()

# Create a list of files on the system having permissions different from what
# is expected by the RPM database
FILES_WITH_INCORRECT_PERMS=($(rpm -Va --nofiledigest | awk '{ if (substr($0,6,1)=="U" || substr($0,7,1)=="G") print $NF }'))

# For each file path from that list:
# * Determine the RPM package the file path is shipped by,
# * Include it into SETPERMS_RPM_LIST array

for FILE_PATH in "${FILES_WITH_INCORRECT_PERMS[@]}"
do
        RPM_PACKAGE=$(rpm -qf "$FILE_PATH")
	SETPERMS_RPM_LIST+=("$RPM_PACKAGE")
done

# Remove duplicate mention of same RPM in $SETPERMS_RPM_LIST (if any)
SETPERMS_RPM_LIST=( $(printf "%s\n" "${SETPERMS_RPM_LIST[@]}" | sort -u) )

# For each of the RPM packages left in the list -- reset its permissions to the
# correct values
for RPM_PACKAGE in "${SETPERMS_RPM_LIST[@]}"
do
        rpm --setugids "${RPM_PACKAGE}"
done
