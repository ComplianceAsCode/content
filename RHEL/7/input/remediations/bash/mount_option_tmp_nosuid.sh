# platform = Red Hat Enterprise Linux 7
NEW_OPT="nosuid"

if [ $(grep " \/tmp " /etc/fstab | grep -c "$NEW_OPT" ) -eq 0 ]; then
        MNT_OPTS=$(grep " \/tmp " /etc/fstab | awk '{print $4}')
        sed -i "s/\( \/tmp.*${MNT_OPTS}\)/\1,${NEW_OPT}/" /etc/fstab
        
        if [ $MNT_OPTS = "defaults" ]
        then
        	sed -i "s/defaults,//" /etc/fstab
        fi
fi
