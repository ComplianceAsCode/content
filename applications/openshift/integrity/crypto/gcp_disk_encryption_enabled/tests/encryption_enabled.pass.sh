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
        "name": "cluster",
    },
    "spec": {
        "platformSpec": {
            "type": "GCP"
        }
    },
    "status": {
        "platform": "GCP",
        "platformStatus": {
            "gcp": {
                "projectID": "openshift-gce-devel-ci",
                "region": "us-central1"
            },
            "type": "GCP"
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
                    "machine.openshift.io/memoryMb": "15360",
                    "machine.openshift.io/vCPU": "4"
                },
                "creationTimestamp": "2021-11-02T15:04:09Z",
                "generation": 1,
                "labels": {
                    "machine.openshift.io/cluster-api-cluster": "ci-ln-jz1ylt2-72292-bqcd8"
                },
                "name": "ci-ln-jz1ylt2-72292-bqcd8-worker-a",
                "namespace": "openshift-machine-api",
                "resourceVersion": "17876",
                "uid": "6d06e16f-85a5-4a2c-b631-defb259a9558"
            },
            "spec": {
                "replicas": 1,
                "selector": {
                    "matchLabels": {
                        "machine.openshift.io/cluster-api-cluster": "ci-ln-jz1ylt2-72292-bqcd8",
                        "machine.openshift.io/cluster-api-machineset": "ci-ln-jz1ylt2-72292-bqcd8-worker-a"
                    }
                },
                "template": {
                    "metadata": {
                        "labels": {
                            "machine.openshift.io/cluster-api-cluster": "ci-ln-jz1ylt2-72292-bqcd8",
                            "machine.openshift.io/cluster-api-machine-role": "worker",
                            "machine.openshift.io/cluster-api-machine-type": "worker",
                            "machine.openshift.io/cluster-api-machineset": "ci-ln-jz1ylt2-72292-bqcd8-worker-a"
                        }
                    },
                    "spec": {
                        "metadata": {},
                        "providerSpec": {
                            "value": {
                                "apiVersion": "gcpprovider.openshift.io/v1beta1",
                                "canIPForward": false,
                                "credentialsSecret": {
                                    "name": "gcp-cloud-credentials"
                                },
                                "deletionProtection": false,
                                "disks": [
                                    {
                                        "autoDelete": true,
                                        "boot": true,
                                        "image": "projects/rhcos-cloud/global/images/rhcos-410-84-202110140201-0-gcp-x86-64",
                                        "labels": null,
                                        "sizeGb": 128,
                                        "type": "pd-ssd",
                                        "encryptionKey": {
                                            "kmsKey": {
                                                "name":
                                                "machine-encryption-key",
                                                "keyRing": "openshift-encrpytion-ring",
                                                "location": "global",
                                                "projectID": "openshift-gcp-project"
                                            },
                                            "kmsKeyServiceAccount": "openshift-service-account@openshift-gcp-project.iam.gserviceaccount.com"
                                        }
                                    }
                                ],
                                "kind": "GCPMachineProviderSpec",
                                "machineType": "n1-standard-4",
                                "metadata": {
                                    "creationTimestamp": null
                                },
                                "networkInterfaces": [
                                    {
                                        "network": "ci-ln-jz1ylt2-72292-bqcd8-network",
                                        "subnetwork": "ci-ln-jz1ylt2-72292-bqcd8-worker-subnet"
                                    }
                                ],
                                "projectID": "openshift-gce-devel-ci",
                                "region": "us-central1",
                                "serviceAccounts": [
                                    {
                                        "email": "ci-ln-jz1ylt2-72292-bqcd8-w@openshift-gce-devel-ci.iam.gserviceaccount.com",
                                        "scopes": [
                                            "https://www.googleapis.com/auth/cloud-platform"
                                        ]
                                    }
                                ],
                                "tags": [
                                    "ci-ln-jz1ylt2-72292-bqcd8-worker"
                                ],
                                "userDataSecret": {
                                    "name": "worker-user-data"
                                },
                                "zone": "us-central1-a"
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
        },
        {
            "apiVersion": "machine.openshift.io/v1beta1",
            "kind": "MachineSet",
            "metadata": {
                "annotations": {
                    "machine.openshift.io/memoryMb": "15360",
                    "machine.openshift.io/vCPU": "4"
                },
                "creationTimestamp": "2021-11-02T15:04:10Z",
                "generation": 1,
                "labels": {
                    "machine.openshift.io/cluster-api-cluster": "ci-ln-jz1ylt2-72292-bqcd8"
                },
                "name": "ci-ln-jz1ylt2-72292-bqcd8-worker-b",
                "namespace": "openshift-machine-api",
                "resourceVersion": "19200",
                "uid": "2aa11a8f-a629-4b4f-beb9-dead2678d58c"
            },
            "spec": {
                "replicas": 1,
                "selector": {
                    "matchLabels": {
                        "machine.openshift.io/cluster-api-cluster": "ci-ln-jz1ylt2-72292-bqcd8",
                        "machine.openshift.io/cluster-api-machineset": "ci-ln-jz1ylt2-72292-bqcd8-worker-b"
                    }
                },
                "template": {
                    "metadata": {
                        "labels": {
                            "machine.openshift.io/cluster-api-cluster": "ci-ln-jz1ylt2-72292-bqcd8",
                            "machine.openshift.io/cluster-api-machine-role": "worker",
                            "machine.openshift.io/cluster-api-machine-type": "worker",
                            "machine.openshift.io/cluster-api-machineset": "ci-ln-jz1ylt2-72292-bqcd8-worker-b"
                        }
                    },
                    "spec": {
                        "metadata": {},
                        "providerSpec": {
                            "value": {
                                "apiVersion": "gcpprovider.openshift.io/v1beta1",
                                "canIPForward": false,
                                "credentialsSecret": {
                                    "name": "gcp-cloud-credentials"
                                },
                                "deletionProtection": false,
                                "disks": [
                                    {
                                        "autoDelete": true,
                                        "boot": true,
                                        "image": "projects/rhcos-cloud/global/images/rhcos-410-84-202110140201-0-gcp-x86-64",
                                        "labels": null,
                                        "sizeGb": 128,
                                        "type": "pd-ssd",
                                        "encryptionKey": {
                                            "kmsKey": {
                                                "name":
                                                "machine-encryption-key",
                                                "keyRing": "openshift-encrpytion-ring",
                                                "location": "global",
                                                "projectID": "openshift-gcp-project"
                                            },
                                            "kmsKeyServiceAccount": "openshift-service-account@openshift-gcp-project.iam.gserviceaccount.com"
                                        }
                                    }
                                ],
                                "kind": "GCPMachineProviderSpec",
                                "machineType": "n1-standard-4",
                                "metadata": {
                                    "creationTimestamp": null
                                },
                                "networkInterfaces": [
                                    {
                                        "network": "ci-ln-jz1ylt2-72292-bqcd8-network",
                                        "subnetwork": "ci-ln-jz1ylt2-72292-bqcd8-worker-subnet"
                                    }
                                ],
                                "projectID": "openshift-gce-devel-ci",
                                "region": "us-central1",
                                "serviceAccounts": [
                                    {
                                        "email": "ci-ln-jz1ylt2-72292-bqcd8-w@openshift-gce-devel-ci.iam.gserviceaccount.com",
                                        "scopes": [
                                            "https://www.googleapis.com/auth/cloud-platform"
                                        ]
                                    }
                                ],
                                "tags": [
                                    "ci-ln-jz1ylt2-72292-bqcd8-worker"
                                ],
                                "userDataSecret": {
                                    "name": "worker-user-data"
                                },
                                "zone": "us-central1-b"
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
        },
        {
            "apiVersion": "machine.openshift.io/v1beta1",
            "kind": "MachineSet",
            "metadata": {
                "annotations": {
                    "machine.openshift.io/memoryMb": "15360",
                    "machine.openshift.io/vCPU": "4"
                },
                "creationTimestamp": "2021-11-02T15:04:10Z",
                "generation": 1,
                "labels": {
                    "machine.openshift.io/cluster-api-cluster": "ci-ln-jz1ylt2-72292-bqcd8"
                },
                "name": "ci-ln-jz1ylt2-72292-bqcd8-worker-c",
                "namespace": "openshift-machine-api",
                "resourceVersion": "19253",
                "uid": "eb57399e-8b21-46cb-abe3-9d148fc67e53"
            },
            "spec": {
                "replicas": 1,
                "selector": {
                    "matchLabels": {
                        "machine.openshift.io/cluster-api-cluster": "ci-ln-jz1ylt2-72292-bqcd8",
                        "machine.openshift.io/cluster-api-machineset": "ci-ln-jz1ylt2-72292-bqcd8-worker-c"
                    }
                },
                "template": {
                    "metadata": {
                        "labels": {
                            "machine.openshift.io/cluster-api-cluster": "ci-ln-jz1ylt2-72292-bqcd8",
                            "machine.openshift.io/cluster-api-machine-role": "worker",
                            "machine.openshift.io/cluster-api-machine-type": "worker",
                            "machine.openshift.io/cluster-api-machineset": "ci-ln-jz1ylt2-72292-bqcd8-worker-c"
                        }
                    },
                    "spec": {
                        "metadata": {},
                        "providerSpec": {
                            "value": {
                                "apiVersion": "gcpprovider.openshift.io/v1beta1",
                                "canIPForward": false,
                                "credentialsSecret": {
                                    "name": "gcp-cloud-credentials"
                                },
                                "deletionProtection": false,
                                "disks": [
                                    {
                                        "autoDelete": true,
                                        "boot": true,
                                        "image": "projects/rhcos-cloud/global/images/rhcos-410-84-202110140201-0-gcp-x86-64",
                                        "labels": null,
                                        "sizeGb": 128,
                                        "type": "pd-ssd",
                                        "encryptionKey": {
                                            "kmsKey": {
                                                "name":
                                                "machine-encryption-key",
                                                "keyRing": "openshift-encrpytion-ring",
                                                "location": "global",
                                                "projectID": "openshift-gcp-project"
                                            },
                                            "kmsKeyServiceAccount": "openshift-service-account@openshift-gcp-project.iam.gserviceaccount.com"
                                        }
                                    }
                                ],
                                "kind": "GCPMachineProviderSpec",
                                "machineType": "n1-standard-4",
                                "metadata": {
                                    "creationTimestamp": null
                                },
                                "networkInterfaces": [
                                    {
                                        "network": "ci-ln-jz1ylt2-72292-bqcd8-network",
                                        "subnetwork": "ci-ln-jz1ylt2-72292-bqcd8-worker-subnet"
                                    }
                                ],
                                "projectID": "openshift-gce-devel-ci",
                                "region": "us-central1",
                                "serviceAccounts": [
                                    {
                                        "email": "ci-ln-jz1ylt2-72292-bqcd8-w@openshift-gce-devel-ci.iam.gserviceaccount.com",
                                        "scopes": [
                                            "https://www.googleapis.com/auth/cloud-platform"
                                        ]
                                    }
                                ],
                                "tags": [
                                    "ci-ln-jz1ylt2-72292-bqcd8-worker"
                                ],
                                "userDataSecret": {
                                    "name": "worker-user-data"
                                },
                                "zone": "us-central1-c"
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
        },
        {
            "apiVersion": "machine.openshift.io/v1beta1",
            "kind": "MachineSet",
            "metadata": {
                "annotations": {
                    "machine.openshift.io/memoryMb": "15360",
                    "machine.openshift.io/vCPU": "4"
                },
                "creationTimestamp": "2021-11-02T15:04:11Z",
                "generation": 1,
                "labels": {
                    "machine.openshift.io/cluster-api-cluster": "ci-ln-jz1ylt2-72292-bqcd8"
                },
                "name": "ci-ln-jz1ylt2-72292-bqcd8-worker-f",
                "namespace": "openshift-machine-api",
                "resourceVersion": "9412",
                "uid": "c5826d10-82a5-4db5-aa64-29c90a3e9349"
            },
            "spec": {
                "replicas": 0,
                "selector": {
                    "matchLabels": {
                        "machine.openshift.io/cluster-api-cluster": "ci-ln-jz1ylt2-72292-bqcd8",
                        "machine.openshift.io/cluster-api-machineset": "ci-ln-jz1ylt2-72292-bqcd8-worker-f"
                    }
                },
                "template": {
                    "metadata": {
                        "labels": {
                            "machine.openshift.io/cluster-api-cluster": "ci-ln-jz1ylt2-72292-bqcd8",
                            "machine.openshift.io/cluster-api-machine-role": "worker",
                            "machine.openshift.io/cluster-api-machine-type": "worker",
                            "machine.openshift.io/cluster-api-machineset": "ci-ln-jz1ylt2-72292-bqcd8-worker-f"
                        }
                    },
                    "spec": {
                        "metadata": {},
                        "providerSpec": {
                            "value": {
                                "apiVersion": "gcpprovider.openshift.io/v1beta1",
                                "canIPForward": false,
                                "credentialsSecret": {
                                    "name": "gcp-cloud-credentials"
                                },
                                "deletionProtection": false,
                                "disks": [
                                    {
                                        "autoDelete": true,
                                        "boot": true,
                                        "image": "projects/rhcos-cloud/global/images/rhcos-410-84-202110140201-0-gcp-x86-64",
                                        "labels": null,
                                        "sizeGb": 128,
                                        "type": "pd-ssd",
                                        "encryptionKey": {
                                            "kmsKey": {
                                                "name":
                                                "machine-encryption-key",
                                                "keyRing": "openshift-encrpytion-ring",
                                                "location": "global",
                                                "projectID": "openshift-gcp-project"
                                            },
                                            "kmsKeyServiceAccount": "openshift-service-account@openshift-gcp-project.iam.gserviceaccount.com"
                                        }
                                    }
                                ],
                                "kind": "GCPMachineProviderSpec",
                                "machineType": "n1-standard-4",
                                "metadata": {
                                    "creationTimestamp": null
                                },
                                "networkInterfaces": [
                                    {
                                        "network": "ci-ln-jz1ylt2-72292-bqcd8-network",
                                        "subnetwork": "ci-ln-jz1ylt2-72292-bqcd8-worker-subnet"
                                    }
                                ],
                                "projectID": "openshift-gce-devel-ci",
                                "region": "us-central1",
                                "serviceAccounts": [
                                    {
                                        "email": "ci-ln-jz1ylt2-72292-bqcd8-w@openshift-gce-devel-ci.iam.gserviceaccount.com",
                                        "scopes": [
                                            "https://www.googleapis.com/auth/cloud-platform"
                                        ]
                                    }
                                ],
                                "tags": [
                                    "ci-ln-jz1ylt2-72292-bqcd8-worker"
                                ],
                                "userDataSecret": {
                                    "name": "worker-user-data"
                                },
                                "zone": "us-central1-f"
                            }
                        }
                    }
                }
            },
            "status": {
                "observedGeneration": 1,
                "replicas": 0
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

jq_filter='[.items[] | select(.spec.template.spec.providerSpec.value.disks[0].encryptionKey.kmsKey.name != null) | .metadata.name]'

# Get filtered path. This will actually be read by the scan
filteredpath="$kube_apipath/$machineset_apipath#$(echo -n "$machineset_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath/$machineset_apipath" > "$filteredpath"
