#!/bin/bash
# Original author of the script
#
#    Jan Cerny <jcerny@redhat.com>
#
# Reuse for remediation checking
#
#    Marek Haicman <mhaicman@redhat.com>
#


DOMAIN=${DOMAIN:-"REM_RHEL7"}
TESTED_DATASTREAM="/usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml"
TESTED_DATASTREAM="/home/dahaic/RH/git/upstream/origins/scap-security-guide/build/ssg-rhel7-ds.xml"


SNAP_FIRST="ssg_test_suite_origin"
SSG_PROFILE_PREFIX='xccdf_org.ssgproject.content_profile_'
SSG_RULE_PREFIX='xccdf_org.ssgproject.content_rule_'


if [ -z $1 ]; then
    echo "You need to provide profile name as a parameter!"
    echo
    echo "Domain used: $DOMAIN"
    echo "DataStream used: $TESTED_DATASTREAM"
    echo "Profiles available in the DataStream:"
    oscap info $TESTED_DATASTREAM | grep "$SSG_PROFILE_PREFIX" | sed "s/$SSG_PROFILE_PREFIX//g"
    exit 1
else
    PROFILE=${SSG_PROFILE_PREFIX}${1}
fi

date=$(date +%Y_%m_%d_%H_%M)
result_dir="results_$date"
debug_log="$result_dir/run.debug.log"

mkdir $result_dir

function determine_IP {
    local IP=""
    local count=10
    while [ -z "$IP" ]
    do
        sleep 1
        MAC=$(virsh domiflist $DOMAIN | grep virtio | awk '{ print $5 }')
        [ -z "$MAC" ] && continue
        IP=$(arp | grep "$MAC" | awk '{ print $1 }')
        ((count--))
        if [ "$count" -eq "0" ] && [ -z $IP ]; then
            break
        fi
    done
    echo "$IP"
    return
}


#############################
#
#


# first snapshot, to revert to at the end of whole run
virsh snapshot-create-as --name ${SNAP_FIRST} $DOMAIN &>> $debug_log
if virsh list --inactive | grep -q " $DOMAIN "; then
    echo "Domain \"$DOMAIN\" is inactive, starting"
    virsh start "$DOMAIN" &>> $debug_log
    sleep 20
fi

IP=$(determine_IP)
if [ -z "$IP" ]; then
    echo "IP cannot be determined"
    virsh snapshot-revert --snapshotname ${SNAP_FIRST} $DOMAIN &>> $debug_log
    virsh snapshot-delete --snapshotname ${SNAP_FIRST} $DOMAIN &>> $debug_log
    exit 1
fi

MACHINE="root@${IP}"

ssh $MACHINE rpm -qa openscap &>> $debug_log
ssh $MACHINE oscap --version &>> $debug_log

output_file=$(mktemp)


# after break script, result should contain fail
echo "Initial scan"
REPORT_FILE="$result_dir/initial.html"
oscap-ssh ${MACHINE} 22 xccdf eval --profile ${PROFILE} --progress --oval-results --report $REPORT_FILE $TESTED_DATASTREAM &> ${output_file}
if grep ':error$' ${output_file}; then
    cat ${output_file} &>> $debug_log
    echo "FAIL: There are rules that errored while scanning"
else
    echo "No errors in initial scan"
fi

echo "Starting remediation run"
REPORT_FILE="$result_dir/remediation.html"
oscap-ssh ${MACHINE} 22 xccdf eval --profile ${PROFILE} --progress --remediate --oval-results --report $REPORT_FILE $TESTED_DATASTREAM &> ${output_file}
if grep ':error$' ${output_file}; then
    cat ${output_file} &>> $debug_log
    echo "FAIL: There are rules that errored while scanning/remediating, see report file"
    cp $REPORT_FILE ./$PROFILE.report.html
else
    echo "No errors during scanning / remediation"
fi

echo "Scanning final state"
REPORT_FILE="$result_dir/final.html"
oscap-ssh ${MACHINE} 22 xccdf eval --profile ${PROFILE} --progress --oval-results --report $REPORT_FILE $TESTED_DATASTREAM &> ${output_file}
if grep "$SSG_RULE_PREFIX" ${output_file} | grep -v 'pass$'; then
    cat ${output_file} &>> $debug_log
    echo "FAIL: There are rules not passing after remediation"
else
    echo "No failures after remediation"
fi

rm ${output_file}
echo "#################" >> $debug_log


virsh snapshot-revert --snapshotname ${SNAP_FIRST} $DOMAIN &>> $debug_log
virsh snapshot-delete --snapshotname ${SNAP_FIRST} $DOMAIN &>> $debug_log
