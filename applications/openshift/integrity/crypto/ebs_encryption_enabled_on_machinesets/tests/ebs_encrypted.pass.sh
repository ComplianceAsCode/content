#!/bin/bash

# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"

# Create infra file for CPE to pass
mkdir -p "$kube_apipath/apis/config.openshift.io/v1/infrastructures/"
cat <<EOF > "$kube_apipath/apis/config.openshift.io/v1/infrastructures/cluster"
{
    "apiVersion": "config.openshift.io/v1",
    "kind": "Infrastructure",
    "metadata": {
        "creationTimestamp": "2021-11-03T13:36:29Z",
        "generation": 1,
        "name": "cluster",
        "resourceVersion": "610",
        "uid": "d7cc2f22-766c-4aba-927f-24d3cc0f1c78"
    },
    "spec": {
        "cloudConfig": {
            "name": ""
        },
        "platformSpec": {
            "aws": {},
            "type": "AWS"
        }
    },
    "status": {
        "apiServerInternalURI": "https://api-int.ci-ln-p8l7xlb-76ef8.origin-ci-int-aws.dev.rhcloud.com:6443",
        "apiServerURL": "https://api.ci-ln-p8l7xlb-76ef8.origin-ci-int-aws.dev.rhcloud.com:6443",
        "controlPlaneTopology": "HighlyAvailable",
        "etcdDiscoveryDomain": "",
        "infrastructureName": "ci-ln-p8l7xlb-76ef8-jlqcw",
        "infrastructureTopology": "HighlyAvailable",
        "platform": "AWS",
        "platformStatus": {
            "aws": {
                "region": "us-east-2"
            },
            "type": "AWS"
        }
    }
}
EOF


machinev1beta1="/apis/machine.openshift.io/v1beta1"
machineset_apipath="$machinev1beta1/machinesets?limit=500"
# Create base file (not really needed for scanning but good for
# documentation and readability)
mkdir -p "$kube_apipath/$machinev1beta1"
cat <<EOF > "$kube_apipath/$machineset_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "machine.openshift.io/v1beta1",
            "kind": "MachineSet",
            "metadata": {
                "annotations": {
                    "machine.openshift.io/GPU": "0",
                    "machine.openshift.io/memoryMb": "16384",
                    "machine.openshift.io/vCPU": "4"
                },
                "creationTimestamp": "2021-11-03T13:37:20Z",
                "generation": 1,
                "labels": {
                    "machine.openshift.io/cluster-api-cluster": "ci-ln-p8l7xlb-76ef8-jlqcw"
                },
                "name": "ci-ln-p8l7xlb-76ef8-jlqcw-worker-us-east-2b",
                "namespace": "openshift-machine-api",
                "resourceVersion": "15437",
                "uid": "9ed0d1f2-d45d-4e5b-9340-37505a710245"
            },
            "spec": {
                "replicas": 2,
                "selector": {
                    "matchLabels": {
                        "machine.openshift.io/cluster-api-cluster": "ci-ln-p8l7xlb-76ef8-jlqcw",
                        "machine.openshift.io/cluster-api-machineset": "ci-ln-p8l7xlb-76ef8-jlqcw-worker-us-east-2b"
                    }
                },
                "template": {
                    "metadata": {
                        "labels": {
                            "machine.openshift.io/cluster-api-cluster": "ci-ln-p8l7xlb-76ef8-jlqcw",
                            "machine.openshift.io/cluster-api-machine-role": "worker",
                            "machine.openshift.io/cluster-api-machine-type": "worker",
                            "machine.openshift.io/cluster-api-machineset": "ci-ln-p8l7xlb-76ef8-jlqcw-worker-us-east-2b"
                        }
                    },
                    "spec": {
                        "metadata": {},
                        "providerSpec": {
                            "value": {
                                "ami": {
                                    "id": "ami-03d9208319c96db0c"
                                },
                                "apiVersion": "awsproviderconfig.openshift.io/v1beta1",
                                "blockDevices": [
                                    {
                                        "ebs": {
                                            "encrypted": true,
                                            "iops": 0,
                                            "kmsKey": {
                                                "arn": ""
                                            },
                                            "volumeSize": 120,
                                            "volumeType": "gp2"
                                        }
                                    }
                                ],
                                "credentialsSecret": {
                                    "name": "aws-cloud-credentials"
                                },
                                "deviceIndex": 0,
                                "iamInstanceProfile": {
                                    "id": "ci-ln-p8l7xlb-76ef8-jlqcw-worker-profile"
                                },
                                "instanceType": "m5.xlarge",
                                "kind": "AWSMachineProviderConfig",
                                "metadata": {
                                    "creationTimestamp": null
                                },
                                "placement": {
                                    "availabilityZone": "us-east-2b",
                                    "region": "us-east-2"
                                },
                                "securityGroups": [
                                    {
                                        "filters": [
                                            {
                                                "name": "tag:Name",
                                                "values": [
                                                    "ci-ln-p8l7xlb-76ef8-jlqcw-worker-sg"
                                                ]
                                            }
                                        ]
                                    }
                                ],
                                "subnet": {
                                    "filters": [
                                        {
                                            "name": "tag:Name",
                                            "values": [
                                                "ci-ln-p8l7xlb-76ef8-jlqcw-private-us-east-2b"
                                            ]
                                        }
                                    ]
                                },
                                "tags": [
                                    {
                                        "name": "kubernetes.io/cluster/ci-ln-p8l7xlb-76ef8-jlqcw",
                                        "value": "owned"
                                    },
                                    {
                                        "name": "expirationDate",
                                        "value": "2021-11-03T21:23+0000"
                                    }
                                ],
                                "userDataSecret": {
                                    "name": "worker-user-data"
                                }
                            }
                        }
                    }
                }
            },
            "status": {
                "availableReplicas": 2,
                "fullyLabeledReplicas": 2,
                "observedGeneration": 1,
                "readyReplicas": 2,
                "replicas": 2
            }
        },
        {
            "apiVersion": "machine.openshift.io/v1beta1",
            "kind": "MachineSet",
            "metadata": {
                "annotations": {
                    "machine.openshift.io/GPU": "0",
                    "machine.openshift.io/memoryMb": "16384",
                    "machine.openshift.io/vCPU": "4"
                },
                "creationTimestamp": "2021-11-03T13:37:20Z",
                "generation": 1,
                "labels": {
                    "machine.openshift.io/cluster-api-cluster": "ci-ln-p8l7xlb-76ef8-jlqcw"
                },
                "name": "ci-ln-p8l7xlb-76ef8-jlqcw-worker-us-east-2c",
                "namespace": "openshift-machine-api",
                "resourceVersion": "21328",
                "uid": "73631698-5955-4fe7-8a75-3f4db4a752ae"
            },
            "spec": {
                "replicas": 1,
                "selector": {
                    "matchLabels": {
                        "machine.openshift.io/cluster-api-cluster": "ci-ln-p8l7xlb-76ef8-jlqcw",
                        "machine.openshift.io/cluster-api-machineset": "ci-ln-p8l7xlb-76ef8-jlqcw-worker-us-east-2c"
                    }
                },
                "template": {
                    "metadata": {
                        "labels": {
                            "machine.openshift.io/cluster-api-cluster": "ci-ln-p8l7xlb-76ef8-jlqcw",
                            "machine.openshift.io/cluster-api-machine-role": "worker",
                            "machine.openshift.io/cluster-api-machine-type": "worker",
                            "machine.openshift.io/cluster-api-machineset": "ci-ln-p8l7xlb-76ef8-jlqcw-worker-us-east-2c"
                        }
                    },
                    "spec": {
                        "metadata": {},
                        "providerSpec": {
                            "value": {
                                "ami": {
                                    "id": "ami-03d9208319c96db0c"
                                },
                                "apiVersion": "awsproviderconfig.openshift.io/v1beta1",
                                "blockDevices": [
                                    {
                                        "ebs": {
                                            "encrypted": true,
                                            "iops": 0,
                                            "kmsKey": {
                                                "arn": ""
                                            },
                                            "volumeSize": 120,
                                            "volumeType": "gp2"
                                        }
                                    }
                                ],
                                "credentialsSecret": {
                                    "name": "aws-cloud-credentials"
                                },
                                "deviceIndex": 0,
                                "iamInstanceProfile": {
                                    "id": "ci-ln-p8l7xlb-76ef8-jlqcw-worker-profile"
                                },
                                "instanceType": "m5.xlarge",
                                "kind": "AWSMachineProviderConfig",
                                "metadata": {
                                    "creationTimestamp": null
                                },
                                "placement": {
                                    "availabilityZone": "us-east-2c",
                                    "region": "us-east-2"
                                },
                                "securityGroups": [
                                    {
                                        "filters": [
                                            {
                                                "name": "tag:Name",
                                                "values": [
                                                    "ci-ln-p8l7xlb-76ef8-jlqcw-worker-sg"
                                                ]
                                            }
                                        ]
                                    }
                                ],
                                "subnet": {
                                    "filters": [
                                        {
                                            "name": "tag:Name",
                                            "values": [
                                                "ci-ln-p8l7xlb-76ef8-jlqcw-private-us-east-2c"
                                            ]
                                        }
                                    ]
                                },
                                "tags": [
                                    {
                                        "name": "kubernetes.io/cluster/ci-ln-p8l7xlb-76ef8-jlqcw",
                                        "value": "owned"
                                    },
                                    {
                                        "name": "expirationDate",
                                        "value": "2021-11-03T21:23+0000"
                                    }
                                ],
                                "userDataSecret": {
                                    "name": "worker-user-data"
                                }
                            }
                        }
                    }
                }
            },
            "status": {
                "availableReplicas": 1,
                "fullyLabeledReplicas": 1,
                "observedGeneration": 1,
                "readyReplicas": 1,
                "replicas": 1
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
EOF

jq_filter='[.items[] | .spec.template.spec.providerSpec.value.blockDevices[0].ebs.encrypted] | map(. == true)'

# Get filtered path. This will actually be read by the scan
filteredpath="$kube_apipath/$machineset_apipath#$(echo -n "$machineset_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath/$machineset_apipath" > "$filteredpath"