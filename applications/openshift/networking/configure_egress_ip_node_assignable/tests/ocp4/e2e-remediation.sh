#!/bin/bash
set -xe

echo "Labeling Node for egress IP"

NODENAME=`oc get node | tail -1 | cut -d" " -f1`
oc label node $NODENAME k8s.ovn.org/egress-assignable=""

sleep 5
