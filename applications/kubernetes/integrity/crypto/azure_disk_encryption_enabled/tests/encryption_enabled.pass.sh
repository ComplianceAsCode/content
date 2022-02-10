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
        "name": "cluster"
    },
    "spec": {
        "platformSpec": {
            "type": "Azure"
        }
    },
    "status": {
        "platform": "Azure",
        "platformStatus": {
            "azure": {
                "cloudName": "AzurePublicCloud"
            },
            "type": "Azure"
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
                "creationTimestamp": "2021-11-02T12:47:47Z",
                "generation": 1,
                "labels": {
                    "machine.openshift.io/cluster-api-cluster": "ci-ln-7s758l2-1d09d-5924w",
                    "machine.openshift.io/cluster-api-machine-role": "worker",
                    "machine.openshift.io/cluster-api-machine-type": "worker"
                },
                "name": "ci-ln-7s758l2-1d09d-5924w-worker-westus",
                "namespace": "openshift-machine-api",
                "resourceVersion": "19495",
                "uid": "4508e330-64ec-4947-9cb9-ee172f7ff079"
            },
            "spec": {
                "replicas": 3,
                "selector": {
                    "matchLabels": {
                        "machine.openshift.io/cluster-api-cluster": "ci-ln-7s758l2-1d09d-5924w",
                        "machine.openshift.io/cluster-api-machineset": "ci-ln-7s758l2-1d09d-5924w-worker-westus"
                    }
                },
                "template": {
                    "metadata": {
                        "labels": {
                            "machine.openshift.io/cluster-api-cluster": "ci-ln-7s758l2-1d09d-5924w",
                            "machine.openshift.io/cluster-api-machine-role": "worker",
                            "machine.openshift.io/cluster-api-machine-type": "worker",
                            "machine.openshift.io/cluster-api-machineset": "ci-ln-7s758l2-1d09d-5924w-worker-westus"
                        }
                    },
                    "spec": {
                        "metadata": {},
                        "providerSpec": {
                            "value": {
                                "apiVersion": "azureproviderconfig.openshift.io/v1beta1",
                                "credentialsSecret": {
                                    "name": "azure-cloud-credentials",
                                    "namespace": "openshift-machine-api"
                                },
                                "image": {
                                    "offer": "",
                                    "publisher": "",
                                    "resourceID": "/resourceGroups/ci-ln-7s758l2-1d09d-5924w-rg/providers/Microsoft.Compute/images/ci-ln-7s758l2-1d09d-5924w",
                                    "sku": "",
                                    "version": ""
                                },
                                "kind": "AzureMachineProviderSpec",
                                "location": "westus",
                                "managedIdentity": "ci-ln-7s758l2-1d09d-5924w-identity",
                                "metadata": {
                                    "creationTimestamp": null
                                },
                                "networkResourceGroup": "ci-ln-7s758l2-1d09d-5924w-rg",
                                "osDisk": {
                                    "diskSizeGB": 128,
                                    "managedDisk": {
                                        "storageAccountType": "Premium_LRS",
                                        "diskEncryptionSet": {
                                            "id": "/subscriptions/1234/resourceGroups/12345/providers/Microsoft.Compute/diskEncryptionSets/foobar"
                                        }
                                    },
                                    "osType": "Linux"
                                },
                                "publicIP": false,
                                "publicLoadBalancer": "ci-ln-7s758l2-1d09d-5924w",
                                "resourceGroup": "ci-ln-7s758l2-1d09d-5924w-rg",
                                "subnet": "ci-ln-7s758l2-1d09d-5924w-worker-subnet",
                                "userDataSecret": {
                                    "name": "worker-user-data"
                                },
                                "vmSize": "Standard_D4s_v3",
                                "vnet": "ci-ln-7s758l2-1d09d-5924w-vnet",
                                "zone": ""
                            }
                        }
                    }
                }
            },
            "status": {
                "availableReplicas": 3,
                "fullyLabeledReplicas": 3,
                "observedGeneration": 1,
                "readyReplicas": 3,
                "replicas": 3
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

jq_filter='[.items[] | select(.spec.template.spec.providerSpec.value.osDisk.managedDisk.diskEncryptionSet.id != null) | .metadata.name]'

# Get filtered path. This will actually be read by the scan
filteredpath="$kube_apipath/$machineset_apipath#$(echo -n "$machineset_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath/$machineset_apipath" > "$filteredpath"
