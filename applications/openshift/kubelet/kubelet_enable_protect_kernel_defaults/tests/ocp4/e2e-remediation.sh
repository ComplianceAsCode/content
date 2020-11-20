#!/bin/bash
set -xe

echo "applying kernel tuning for kubelet"
cat << EOF | oc apply --server-side -f -
---
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: 75-master-kubelet-sysctls
spec:
  config:
    ignition:
      version: 3.1.0
    storage:
      files:
      - contents:
          source: data:,vm.overcommit_memory%3D1%0Avm.panic_on_oom%3D0%0Akernel.panic%3D10%0Akernel.panic_on_oops%3D1%0Akernel.keys.root_maxkeys%3D1000000%0Akernel.keys.root_maxbytes%3D25000000
        mode: 0644
        path: /etc/sysctl.d/90-kubelet.conf
---
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 75-worker-kubelet-sysctls
spec:
  config:
    ignition:
      version: 3.1.0
    storage:
      files:
      - contents:
          source: data:,vm.overcommit_memory%3D1%0Avm.panic_on_oom%3D0%0Akernel.panic%3D10%0Akernel.panic_on_oops%3D1%0Akernel.keys.root_maxkeys%3D1000000%0Akernel.keys.root_maxbytes%3D25000000
        mode: 0644
        path: /etc/sysctl.d/90-kubelet.conf

EOF

sleep 20

echo "waiting for workers to update"
while true; do
		status=$(oc get mcp/worker | grep worker | awk '{ print $3 $4 }')
		if [ "$status" == "TrueFalse" ]; then
			echo "workers have been updated"
			break
		fi
		sleep 1
done

echo "waiting for masters to update"
while true; do
		status=$(oc get mcp/master | grep master | awk '{ print $3 $4 }')
		if [ "$status" == "TrueFalse" ]; then
			echo "masters have been updated"
			break
		fi
		sleep 1
done

sleep 20

echo "applying protectKernelDefaults"
cat << EOF | oc apply --server-side -f -
---
apiVersion: machineconfiguration.openshift.io/v1
kind: KubeletConfig
metadata:
  name: master-protect-kernel-defaults
spec:
  machineConfigPoolSelector:
    matchLabels:
      pools.operator.machineconfiguration.openshift.io/master: ""
  kubeletConfig:
    protectKernelDefaults: true
---
apiVersion: machineconfiguration.openshift.io/v1
kind: KubeletConfig
metadata:
  name: worker-protect-kernel-defaults
spec:
  machineConfigPoolSelector:
    matchLabels:
      pools.operator.machineconfiguration.openshift.io/worker: ""
  kubeletConfig:
    protectKernelDefaults: true
EOF

sleep 30

echo "waiting for workers to update"
while true; do
		status=$(oc get mcp/worker | grep worker | awk '{ print $3 $4 }')
		if [ "$status" == "TrueFalse" ]; then
			break
		fi
		sleep 1
done

echo "waiting for masters to update"
while true; do
		status=$(oc get mcp/master | grep master | awk '{ print $3 $4 }')
		if [ "$status" == "TrueFalse" ]; then
			echo "masters have been updated"
			break
		fi
		sleep 1
done

exit 0
