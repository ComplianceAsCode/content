# platform = Red Hat Enterprise Linux 7
FSTAB=/etc/fstab
SED=`which sed`
NEW_OPT="nosuid"

if [ $(grep " \/tmp " ${FSTAB} | grep -c "$NEW_OPT" ) -eq 0 ]; then
        MNT_OPTS=$(grep " \/tmp " ${FSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/tmp.*${MNT_OPTS}\)/\1,${NEW_OPT}/" ${FSTAB}
        
        if [ $MNT_OPTS = "defaults" ]
        then
        	${SED} -i "s/defaults,//" ${FSTAB}
        fi
fi