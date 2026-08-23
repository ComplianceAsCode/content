#!/bin/bash
# remediation = none
# packages = jq

kube_apipath="/kubernetes-api-resources"
mkdir -p "$kube_apipath/apis/machineconfiguration.openshift.io/v1"
master_apipath="/apis/machineconfiguration.openshift.io/v1/machineconfigpools"

cat <<EOF > "$kube_apipath$master_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfigPool",
            "metadata": {
                "creationTimestamp": "2021-01-04T14:27:26Z",
                "generation": 28,
                "labels": {
                    "machineconfiguration.openshift.io/mco-built-in": "",
                    "operator.machineconfiguration.openshift.io/required-for-upgrade": "",
                    "pools.operator.machineconfiguration.openshift.io/master": ""
                },
                "name": "master",
                "resourceVersion": "1155401403",
                "uid": "4ae68800-4d14-4d0e-a2b1-7104f28bf80a"
            },
            "spec": {
                "configuration": {
                    "name": "rendered-master-20de05f95332a16cf0e41fc15fd58039",
                    "source": [
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "00-master"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "01-master-container-runtime"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "01-master-kubelet"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-master-chrony-configuration"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-master-generated-crio-add-inheritable-capabilities"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-master-generated-crio-seccomp-use-default"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-master-generated-registries"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-master-ssh"
                        }
                    ]
                },
                "machineConfigSelector": {
                    "matchLabels": {
                        "machineconfiguration.openshift.io/role": "master"
                    }
                },
                "nodeSelector": {
                    "matchLabels": {
                        "node-role.kubernetes.io/master": ""
                    }
                },
                "paused": false
            },
            "status": {
                "conditions": [
                    {
                        "lastTransitionTime": "2023-11-07T11:00:52Z",
                        "message": "",
                        "reason": "",
                        "status": "False",
                        "type": "NodeDegraded"
                    },
                    {
                        "lastTransitionTime": "2024-02-29T14:42:13Z",
                        "message": "",
                        "reason": "",
                        "status": "False",
                        "type": "RenderDegraded"
                    },
                    {
                        "lastTransitionTime": "2024-02-29T14:42:16Z",
                        "message": "",
                        "reason": "",
                        "status": "False",
                        "type": "Degraded"
                    },
                    {
                        "lastTransitionTime": "2024-03-03T22:26:49Z",
                        "message": "All nodes are updated with rendered-master-20de05f95332a16cf0e41fc15fd58039",
                        "reason": "",
                        "status": "True",
                        "type": "Updated"
                    },
                    {
                        "lastTransitionTime": "2024-03-03T22:26:49Z",
                        "message": "",
                        "reason": "",
                        "status": "False",
                        "type": "Updating"
                    }
                ],
                "configuration": {
                    "name": "rendered-master-20de05f95332a16cf0e41fc15fd58039",
                    "source": [
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "00-master"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "01-master-container-runtime"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "01-master-kubelet"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-master-chrony-configuration"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-master-generated-crio-add-inheritable-capabilities"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-master-generated-crio-seccomp-use-default"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-master-generated-registries"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-master-ssh"
                        }
                    ]
                },
                "degradedMachineCount": 0,
                "machineCount": 3,
                "observedGeneration": 28,
                "readyMachineCount": 3,
                "unavailableMachineCount": 0,
                "updatedMachineCount": 3
            }
        },
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfigPool",
            "metadata": {
                "creationTimestamp": "2021-01-04T14:27:26Z",
                "generation": 28,
                "labels": {
                    "machineconfiguration.openshift.io/mco-built-in": "",
                    "pools.operator.machineconfiguration.openshift.io/worker": ""
                },
                "name": "worker",
                "resourceVersion": "1145698233",
                "uid": "dfba5d38-515c-4715-b30e-8a2f7d78ff23"
            },
            "spec": {
                "configuration": {
                    "name": "rendered-worker-f4e5b015e49ebe23158b1ac1029b13fb",
                    "source": [
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "00-worker"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "01-worker-container-runtime"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "01-worker-kubelet"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-worker-chrony-configuration"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-worker-generated-crio-add-inheritable-capabilities"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-worker-generated-crio-seccomp-use-default"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-worker-generated-registries"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-worker-ssh"
                        }
                    ]
                },
                "machineConfigSelector": {
                    "matchLabels": {
                        "machineconfiguration.openshift.io/role": "worker"
                    }
                },
                "nodeSelector": {
                    "matchLabels": {
                        "node-role.kubernetes.io/worker": ""
                    }
                },
                "paused": false
            },
            "status": {
                "conditions": [
                    {
                        "lastTransitionTime": "2021-09-16T13:54:19Z",
                        "message": "",
                        "reason": "",
                        "status": "False",
                        "type": "NodeDegraded"
                    },
                    {
                        "lastTransitionTime": "2024-01-14T00:00:08Z",
                        "message": "",
                        "reason": "",
                        "status": "False",
                        "type": "RenderDegraded"
                    },
                    {
                        "lastTransitionTime": "2024-01-14T00:00:13Z",
                        "message": "",
                        "reason": "",
                        "status": "False",
                        "type": "Degraded"
                    },
                    {
                        "lastTransitionTime": "2024-02-26T16:30:22Z",
                        "message": "All nodes are updated with rendered-worker-f4e5b015e49ebe23158b1ac1029b13fb",
                        "reason": "",
                        "status": "True",
                        "type": "Updated"
                    },
                    {
                        "lastTransitionTime": "2024-02-26T16:30:22Z",
                        "message": "",
                        "reason": "",
                        "status": "False",
                        "type": "Updating"
                    }
                ],
                "configuration": {
                    "name": "rendered-worker-f4e5b015e49ebe23158b1ac1029b13fb",
                    "source": [
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "00-worker"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "01-worker-container-runtime"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "01-worker-kubelet"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-worker-chrony-configuration"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-worker-generated-crio-add-inheritable-capabilities"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-worker-generated-crio-seccomp-use-default"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-worker-generated-registries"
                        },
                        {
                            "apiVersion": "machineconfiguration.openshift.io/v1",
                            "kind": "MachineConfig",
                            "name": "99-worker-ssh"
                        }
                    ]
                },
                "degradedMachineCount": 0,
                "machineCount": 1,
                "observedGeneration": 28,
                "readyMachineCount": 1,
                "unavailableMachineCount": 0,
                "updatedMachineCount": 1
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": ""
    }
}
EOF

jq_filter='[.items[] | select(.status.machineCount == 1 or .status.machineCount == 0) | .metadata.name]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$master_apipath#$(echo -n "$master_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$master_apipath" > "$filteredpath"
