# platform = multi_platform_ol
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
# Get /sapmnt/SID/exe from /sapmnt. Works for multiple SIDs.
SIDexelist=$(find /sapmnt -regex '^/sapmnt/[A-Z][A-Z0-9][A-Z0-9]/exe$')

for i in $SIDexelist ; do
        SID=${i:8:3}
        sidadm=$(echo "$SID" | sed -e 's/\(.*\)/\L\1/')adm
        uid=$(id -u $sidadm)
        chown $sidadm $i
done
