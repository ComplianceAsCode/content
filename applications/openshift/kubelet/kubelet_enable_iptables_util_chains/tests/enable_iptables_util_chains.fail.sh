#!/bin/bash
# remediation = none

mkdir -p /etc/kubernetes

cat << EOF > /etc/kubernetes/kubelet.conf
{

}
EOF
