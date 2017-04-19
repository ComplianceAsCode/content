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

DIR_BASE="/tmp/ssg_testsuite/"
TESTED_DATASTREAM="/usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml"

SNAP_FIRST="ssg_test_suite_origin"
SNAP_SECOND="ssg_test_suite_rule_dir"
SNAP_THIRD="ssg_test_suite_break_script"

CHOICE=$1


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
        if [ "$count" -eq "0" ]; then
            break
        fi
    done
    echo "$IP"
    return
}

function test_all_domains {
    local test_dir="$1"
    local result_dir="$2"
    local DOMAIN=""
    for DOMAIN in $DOMAINS; do
        test_single_domain "$DOMAIN" "$test_dir" "$result_dir"
    done
}

function test_single_domain {
    true
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

for rule_dir in `find data/ -name "tailoring.xml" | xargs dirname | sort -u`; do
    # prepare for tests in this directory
    # directory contents:
    # *.prepare.sh - Scripts are run before local snapshot - might contain stuff useful to all breaks in directory.
    # *.break.sh - Every break script is run separately, tested by tailoring every time. State is reverted by local snapshot afterwards.
    # tailoring.xml - Tailoring file, which is supposed to have reference changed to tested datastream.
    # $TESTED_DATASTREAM - that's what we actually test

    [ -z "$CHOICE" ] || [[ "$rule_dir" =~ .*$CHOICE.* ]] || continue

    remote_dir="${DIR_BASE}/$rule_dir"
    local_tailoring="${rule_dir}/tailoring.xml"
    temp_tailoring="tailoring.personalized.xml"
    remote_tailoring_file="${remote_dir}/tailoring.xml"
    remote_tested_ds="$remote_dir/$(basename $TESTED_DATASTREAM)"
    profile_supplanted="xccdf_org.ssgproject.content_profile_ssg_testsuite"
    ssh ${MACHINE} "mkdir -p '$remote_dir'" &>> $debug_log
    # no whitespaces in script names, please
    scp "$TESTED_DATASTREAM" "$rule_dir/"* ${MACHINE}:${remote_dir} &>> $debug_log

    # tailoring in the rule_dir needs to be updated to point to the correct datastream
    # profile name needs to be normalized
    sed /xccdf:benchmark/s%href=\"\[^\"\]*%href=\"$remote_tested_ds% ${local_tailoring} > $temp_tailoring
    sed -i /xccdf:Profile/s%id=\"\[^\"\]*%id=\"$profile_supplanted% $temp_tailoring
    scp $temp_tailoring ${MACHINE}:${remote_tailoring_file} &>> $debug_log
    rm $temp_tailoring

    #if there are some prepare scripts, run them before local snapshot
    for prepare_script_path in $(find $rule_dir -name "*.prepare.sh" | sort -u);do
        prepare_script_id=${prepare_script_path#*/}
        prepare_script_id=${prepare_script_id%%.prepare.sh}
        echo "# Performing ${prepare_script_id} prepare script" &>> $debug_log
        prepare_script="${remote_dir}/$(basename $prepare_script_path)"
        ssh ${MACHINE} chmod +x $prepare_script &>> $debug_log
        ssh ${MACHINE} $prepare_script &>> $debug_log
    done
    echo "#################" >> $debug_log

    virsh snapshot-create-as --name ${SNAP_SECOND} $DOMAIN &>> $debug_log

    # now perform breakage with every break script and remediation based on
    # accompanied tailoring, on clean snapshot every time
    for break_script_path in $(find $rule_dir -name "*.break.sh" | sort -u);do
        break_script_id=${break_script_path#*/}
        break_script_id=${break_script_id%%.break.sh}
        echo "# Performing ${break_script_id}" | tee -a $debug_log
        break_script="${remote_dir}/$(basename $break_script_path)"
        output_file="output"
        report_file="${break_script_id//\//\_}".html
        virsh snapshot-create-as --name ${SNAP_THIRD} $DOMAIN &>> $debug_log

        ssh ${MACHINE} chmod +x $break_script
        ssh ${MACHINE} $break_script &>> $debug_log

        # after break script, result should contain fail
        ssh ${MACHINE} oscap xccdf eval --tailoring-file $remote_tailoring_file --profile ${profile_supplanted} --progress --report $report_file $remote_tested_ds &> ${output_file}
        if ! grep -q ':fail$' ${output_file}; then
            cat ${output_file} &>> $debug_log
            echo "ERROR: Break script ${break_script_id} failed to break the machine, no point in going further"
            virsh snapshot-revert --snapshotname ${SNAP_THIRD} $DOMAIN &>> $debug_log
            virsh snapshot-delete --snapshotname ${SNAP_THIRD} $DOMAIN &>> $debug_log
            continue
        fi
        if grep ':error$' ${output_file}; then
            cat ${output_file} &>> $debug_log
            echo "FAIL: There is a rule which errored, no point in going further "
            virsh snapshot-revert --snapshotname ${SNAP_THIRD} $DOMAIN &>> $debug_log
            virsh snapshot-delete --snapshotname ${SNAP_THIRD} $DOMAIN &>> $debug_log
            continue
        fi

        ssh ${MACHINE} oscap xccdf eval --tailoring-file $remote_tailoring_file --profile ${profile_supplanted} --remediate --progress --report $report_file $remote_tested_ds &> ${output_file}
        if grep -q ':error$' ${output_file};then
            echo "FAIL: Remediation for $break_script_id is faulty!"
            scp ${MACHINE}:./$report_file $result_dir &>> $debug_log
            cat ${output_file} &>> $debug_log
            virsh snapshot-revert --snapshotname ${SNAP_THIRD} $DOMAIN &>> $debug_log
            virsh snapshot-delete --snapshotname ${SNAP_THIRD} $DOMAIN &>> $debug_log
            continue
        fi
        cat ${output_file} &>> $debug_log
        ssh ${MACHINE} oscap xccdf eval --tailoring-file $remote_tailoring_file --profile ${profile_supplanted} --progress  $remote_tested_ds &> ${output_file}
        grep -q ':fail$' ${output_file} && echo "FAIL: Remediation for $break_script_id is probably missing!"
        cat ${output_file} &>> $debug_log
        
        virsh snapshot-revert --snapshotname ${SNAP_THIRD} $DOMAIN &>> $debug_log
        virsh snapshot-delete --snapshotname ${SNAP_THIRD} $DOMAIN &>> $debug_log
    done
    rm ${output_file}
    echo "#################" >> $debug_log

    virsh snapshot-revert --snapshotname ${SNAP_SECOND} $DOMAIN &>> $debug_log
    virsh snapshot-delete --snapshotname ${SNAP_SECOND} $DOMAIN &>> $debug_log

done

virsh snapshot-revert --snapshotname ${SNAP_FIRST} $DOMAIN &>> $debug_log
virsh snapshot-delete --snapshotname ${SNAP_FIRST} $DOMAIN &>> $debug_log
