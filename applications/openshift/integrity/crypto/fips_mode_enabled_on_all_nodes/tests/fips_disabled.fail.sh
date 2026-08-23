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


machineconfigv1="/apis/machineconfiguration.openshift.io/v1"
machineconfig_apipath="$machineconfigv1/machineconfigs"
# Create base file (not really needed for scanning but good for
# documentation and readability)
mkdir -p "$kube_apipath/$machineconfigv1"
cat <<EOF > "$kube_apipath/$machineconfig_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfig",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/generated-by-controller-version": "33286190af0d4d340af5c61e603d185780e74b39"
                },
                "creationTimestamp": "2021-11-03T13:39:51Z",
                "generation": 1,
                "labels": {
                    "machineconfiguration.openshift.io/role": "master"
                },
                "name": "00-master",
                "ownerReferences": [
                    {
                        "apiVersion": "machineconfiguration.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "ControllerConfig",
                        "name": "machine-config-controller",
                        "uid": "04e946af-d1a0-4b73-9092-9e787fa55070"
                    }
                ],
                "resourceVersion": "8059",
                "uid": "da3e5cca-95a2-4f27-b8b9-092f2a95f4c7"
            },
            "spec": {
                "config": {
                    "ignition": {
                        "version": "3.2.0"
                    },
                    "storage": {
                        "files": [
                            {
                                "contents": {
                                    "source": "data:,%5Bmain%5D%0Aplugins%3Dkeyfile%2Cifcfg-rh%0A%5Bkeyfile%5D%0Apath%3D%2Fetc%2FNetworkManager%2FsystemConnectionsMerged%0A"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/NetworkManager/conf.d/99-keyfiles.conf"
                            },
                            {
                                "contents": {
                                    "source": "data:,"
                                },
                                "mode": 384,
                                "overwrite": true,
                                "path": "/etc/pki/ca-trust/source/anchors/openshift-config-user-ca-bundle.crt"
                            },
                            {
                                "contents": {
                                    "source": "data:,%23!%2Fbin%2Fbash%0A%23%20Workaround%3A%0A%23%20https%3A%2F%2Fbugzilla.redhat.com%2Fshow_bug.cgi%3Fid%3D1941714%0A%23%20https%3A%2F%2Fbugzilla.redhat.com%2Fshow_bug.cgi%3Fid%3D1935539%0A%23%20https%3A%2F%2Fbugzilla.redhat.com%2Fshow_bug.cgi%3Fid%3D1987108%0A%0Adriver%3D%24(nmcli%20-t%20-m%20tabular%20-f%20general.driver%20dev%20show%20%22%24%7BDEVICE_IFACE%7D%22)%0A%0Aif%20%5B%5B%20%22%242%22%20%3D%3D%20%22up%22%20%26%26%20%22%24%7Bdriver%7D%22%20%3D%3D%20%22vmxnet3%22%20%5D%5D%3B%20then%0A%20%20logger%20-s%20%2299-vsphere-disable-tx-udp-tnl%20triggered%20by%20%24%7B2%7D%20on%20device%20%24%7BDEVICE_IFACE%7D.%22%0A%20%20ethtool%20-K%20%24%7BDEVICE_IFACE%7D%20tx-udp_tnl-segmentation%20off%0A%20%20ethtool%20-K%20%24%7BDEVICE_IFACE%7D%20tx-udp_tnl-csum-segmentation%20off%0A%20%20ethtool%20-K%20%24%7BDEVICE_IFACE%7D%20tx-checksum-ip-generic%20off%0Afi%0A"
                                },
                                "mode": 484,
                                "overwrite": true,
                                "path": "/etc/NetworkManager/dispatcher.d/99-vsphere-disable-tx-udp-tnl"
                            }
                        ]
                    },
                    "systemd": {
                        "units": [
                            {
                                "contents": "[Unit]\nDescription=Fetch kubelet node name from AWS Metadata\n# Wait for NetworkManager to report it's online\nAfter=NetworkManager-wait-online.service\n# Run before kubelet\nBefore=kubelet.service\n\n[Service]\nExecStart=/usr/local/bin/aws-kubelet-nodename\nType=oneshot\n\n[Install]\nWantedBy=network-online.target\n",
                                "enabled": true,
                                "name": "aws-kubelet-nodename.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "",
                                        "name": "10-mco-default-env.conf"
                                    },
                                    {
                                        "contents": "[Service]\nEnvironment=\"ENABLE_PROFILE_UNIX_SOCKET=true\"\n",
                                        "name": "10-mco-profile-unix-socket.conf"
                                    },
                                    {
                                        "contents": "[Service]\nEnvironment=\"GODEBUG=x509ignoreCN=0,madvdontneed=1\"\n",
                                        "name": "10-mco-default-madv.conf"
                                    }
                                ],
                                "name": "crio.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "[Unit]\nConditionPathExists=/enoent\n",
                                        "name": "mco-disabled.conf"
                                    }
                                ],
                                "name": "docker.socket"
                            },
                            {
                                "contents": "[Unit]\nDescription=Dynamically sets the system reserved for the kubelet\nWants=network-online.target\nAfter=network-online.target ignition-firstboot-complete.service\nBefore=kubelet.service crio.service\n[Service]\n# Need oneshot to delay kubelet\nType=oneshot\nRemainAfterExit=yes\nEnvironmentFile=/etc/node-sizing-enabled.env\nExecStart=/bin/bash /usr/local/sbin/dynamic-system-reserved-calc.sh ${NODE_SIZING_ENABLED} ${SYSTEM_RESERVED_MEMORY} ${SYSTEM_RESERVED_CPU}\n[Install]\nRequiredBy=kubelet.service\n",
                                "enabled": true,
                                "name": "kubelet-auto-node-size.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "",
                                        "name": "10-mco-default-env.conf"
                                    },
                                    {
                                        "contents": "[Service]\nEnvironment=\"GODEBUG=x509ignoreCN=0,madvdontneed=1\"\n",
                                        "name": "10-mco-default-madv.conf"
                                    }
                                ],
                                "name": "kubelet.service"
                            },                           
                            {
                                "dropins": [
                                    {
                                        "contents": "# See https://github.com/openshift/machine-config-operator/issues/1897\n[Service]\nNice=10\nIOSchedulingClass=best-effort\nIOSchedulingPriority=6\n",
                                        "name": "mco-controlplane-nice.conf"
                                    }
                                ],
                                "name": "rpm-ostreed.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "[Unit]\nConditionPathExists=/enoent\n",
                                        "name": "mco-disabled.conf"
                                    }
                                ],
                                "name": "zincati.service"
                            }
                        ]
                    }
                },
                "extensions": null,
                "fips": false,
                "kernelArguments": null,
                "kernelType": "",
                "osImageURL": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:ac2ad5b01eed7b0222dabbfb5c6d4b19ddc85bdaab66738f7ff620e4acffb6ac"
            }
        },
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfig",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/generated-by-controller-version": "33286190af0d4d340af5c61e603d185780e74b39"
                },
                "creationTimestamp": "2021-11-03T13:39:51Z",
                "generation": 1,
                "labels": {
                    "machineconfiguration.openshift.io/role": "worker"
                },
                "name": "00-worker",
                "ownerReferences": [
                    {
                        "apiVersion": "machineconfiguration.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "ControllerConfig",
                        "name": "machine-config-controller",
                        "uid": "04e946af-d1a0-4b73-9092-9e787fa55070"
                    }
                ],
                "resourceVersion": "8061",
                "uid": "cc568583-f45e-4240-9111-dce1cf2e9ec7"
            },
            "spec": {
                "config": {
                    "ignition": {
                        "version": "3.2.0"
                    },
                    "storage": {
                        "files": [
                            {
                                "contents": {
                                    "source": "data:,%5Bmain%5D%0Aplugins%3Dkeyfile%2Cifcfg-rh%0A%5Bkeyfile%5D%0Apath%3D%2Fetc%2FNetworkManager%2FsystemConnectionsMerged%0A"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/NetworkManager/conf.d/99-keyfiles.conf"
                            },
                            {
                                "contents": {
                                    "source": "data:,%23!%2Fbin%2Fbash%0A%23%20Workaround%3A%0A%23%20https%3A%2F%2Fbugzilla.redhat.com%2Fshow_bug.cgi%3Fid%3D1941714%0A%23%20https%3A%2F%2Fbugzilla.redhat.com%2Fshow_bug.cgi%3Fid%3D1935539%0A%23%20https%3A%2F%2Fbugzilla.redhat.com%2Fshow_bug.cgi%3Fid%3D1987108%0A%0Adriver%3D%24(nmcli%20-t%20-m%20tabular%20-f%20general.driver%20dev%20show%20%22%24%7BDEVICE_IFACE%7D%22)%0A%0Aif%20%5B%5B%20%22%242%22%20%3D%3D%20%22up%22%20%26%26%20%22%24%7Bdriver%7D%22%20%3D%3D%20%22vmxnet3%22%20%5D%5D%3B%20then%0A%20%20logger%20-s%20%2299-vsphere-disable-tx-udp-tnl%20triggered%20by%20%24%7B2%7D%20on%20device%20%24%7BDEVICE_IFACE%7D.%22%0A%20%20ethtool%20-K%20%24%7BDEVICE_IFACE%7D%20tx-udp_tnl-segmentation%20off%0A%20%20ethtool%20-K%20%24%7BDEVICE_IFACE%7D%20tx-udp_tnl-csum-segmentation%20off%0A%20%20ethtool%20-K%20%24%7BDEVICE_IFACE%7D%20tx-checksum-ip-generic%20off%0Afi%0A"
                                },
                                "mode": 484,
                                "overwrite": true,
                                "path": "/etc/NetworkManager/dispatcher.d/99-vsphere-disable-tx-udp-tnl"
                            }
                        ]
                    },
                    "systemd": {
                        "units": [
                            {
                                "contents": "[Unit]\nDescription=Fetch kubelet node name from AWS Metadata\n# Wait for NetworkManager to report it's online\nAfter=NetworkManager-wait-online.service\n# Run before kubelet\nBefore=kubelet.service\n\n[Service]\nExecStart=/usr/local/bin/aws-kubelet-nodename\nType=oneshot\n\n[Install]\nWantedBy=network-online.target\n",
                                "enabled": true,
                                "name": "aws-kubelet-nodename.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "",
                                        "name": "10-mco-default-env.conf"
                                    },
                                    {
                                        "contents": "[Service]\nEnvironment=\"ENABLE_PROFILE_UNIX_SOCKET=true\"\n",
                                        "name": "10-mco-profile-unix-socket.conf"
                                    },
                                    {
                                        "contents": "[Service]\nEnvironment=\"GODEBUG=x509ignoreCN=0,madvdontneed=1\"\n",
                                        "name": "10-mco-default-madv.conf"
                                    }
                                ],
                                "name": "crio.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "[Unit]\nConditionPathExists=/enoent\n",
                                        "name": "mco-disabled.conf"
                                    }
                                ],
                                "name": "docker.socket"
                            },
                            {
                                "contents": "[Unit]\nDescription=Dynamically sets the system reserved for the kubelet\nWants=network-online.target\nAfter=network-online.target ignition-firstboot-complete.service\nBefore=kubelet.service crio.service\n[Service]\n# Need oneshot to delay kubelet\nType=oneshot\nRemainAfterExit=yes\nEnvironmentFile=/etc/node-sizing-enabled.env\nExecStart=/bin/bash /usr/local/sbin/dynamic-system-reserved-calc.sh ${NODE_SIZING_ENABLED} ${SYSTEM_RESERVED_MEMORY} ${SYSTEM_RESERVED_CPU}\n[Install]\nRequiredBy=kubelet.service\n",
                                "enabled": true,
                                "name": "kubelet-auto-node-size.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "",
                                        "name": "10-mco-default-env.conf"
                                    },
                                    {
                                        "contents": "[Service]\nEnvironment=\"GODEBUG=x509ignoreCN=0,madvdontneed=1\"\n",
                                        "name": "10-mco-default-madv.conf"
                                    }
                                ],
                                "name": "kubelet.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "[Unit]\nConditionPathExists=/enoent\n",
                                        "name": "mco-disabled.conf"
                                    }
                                ],
                                "name": "zincati.service"
                            }
                        ]
                    }
                },
                "extensions": null,
                "fips": false,
                "kernelArguments": null,
                "kernelType": "",
                "osImageURL": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:ac2ad5b01eed7b0222dabbfb5c6d4b19ddc85bdaab66738f7ff620e4acffb6ac"
            }
        },
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfig",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/generated-by-controller-version": "33286190af0d4d340af5c61e603d185780e74b39"
                },
                "creationTimestamp": "2021-11-03T13:39:52Z",
                "generation": 1,
                "labels": {
                    "machineconfiguration.openshift.io/role": "master"
                },
                "name": "01-master-container-runtime",
                "ownerReferences": [
                    {
                        "apiVersion": "machineconfiguration.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "ControllerConfig",
                        "name": "machine-config-controller",
                        "uid": "04e946af-d1a0-4b73-9092-9e787fa55070"
                    }
                ],
                "resourceVersion": "8062",
                "uid": "502984f8-01cf-410b-84e3-331de3223b13"
            },
            "spec": {
                "config": {
                    "ignition": {
                        "version": "3.2.0"
                    },
                    "storage": {
                        "files": [
                            {
                                "contents": {
                                    "source": "data:,unqualified-search-registries%20%3D%20%5B'registry.access.redhat.com'%2C%20'docker.io'%5D%0A"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/containers/registries.conf"
                            },
                            {
                                "contents": {
                                    "source": "data:,%5Bcrio%5D%0Ainternal_wipe%20%3D%20true%0Astorage_driver%20%3D%20%22overlay%22%0Astorage_option%20%3D%20%5B%0A%20%20%20%20%22overlay.override_kernel_check%3D1%22%2C%0A%5D%0A%0A%5Bcrio.api%5D%0Astream_address%20%3D%20%22%22%0Astream_port%20%3D%20%2210010%22%0A%0A%5Bcrio.runtime%5D%0Aselinux%20%3D%20true%0Aconmon%20%3D%20%22%22%0Aconmon_cgroup%20%3D%20%22pod%22%0Adefault_env%20%3D%20%5B%0A%20%20%20%20%22NSS_SDB_USE_CACHE%3Dno%22%2C%0A%5D%0Alog_level%20%3D%20%22info%22%0Acgroup_manager%20%3D%20%22systemd%22%0Adefault_sysctls%20%3D%20%5B%0A%20%20%20%20%22net.ipv4.ping_group_range%3D0%202147483647%22%2C%0A%5D%0Ahooks_dir%20%3D%20%5B%0A%20%20%20%20%22%2Fetc%2Fcontainers%2Foci%2Fhooks.d%22%2C%0A%20%20%20%20%22%2Frun%2Fcontainers%2Foci%2Fhooks.d%22%2C%0A%5D%0Amanage_ns_lifecycle%20%3D%20true%0Aabsent_mount_sources_to_reject%20%3D%20%5B%0A%20%20%20%20%22%2Fetc%2Fhostname%22%2C%0A%5D%0Adrop_infra_ctr%20%3D%20true%0A%0A%5Bcrio.image%5D%0Aglobal_auth_file%20%3D%20%22%2Fvar%2Flib%2Fkubelet%2Fconfig.json%22%0Apause_image%20%3D%20%22quay.io%2Fopenshift-release-dev%2Focp-v4.0-art-dev%40sha256%3Ae73dbbf5048f53d65303d1e80cb588b70813d6cd91654c292998c1dba558bf14%22%0Apause_image_auth_file%20%3D%20%22%2Fvar%2Flib%2Fkubelet%2Fconfig.json%22%0Apause_command%20%3D%20%22%2Fusr%2Fbin%2Fpod%22%0A%0A%5Bcrio.network%5D%0Anetwork_dir%20%3D%20%22%2Fetc%2Fkubernetes%2Fcni%2Fnet.d%2F%22%0Aplugin_dirs%20%3D%20%5B%0A%20%20%20%20%22%2Fvar%2Flib%2Fcni%2Fbin%22%2C%0A%20%20%20%20%22%2Fusr%2Flibexec%2Fcni%22%2C%0A%5D%0A%0A%5Bcrio.metrics%5D%0Aenable_metrics%20%3D%20true%0Ametrics_port%20%3D%209537%0Ametrics_collectors%20%3D%20%5B%0A%20%20%22operations%22%2C%0A%20%20%22operations_latency_microseconds_total%22%2C%0A%20%20%22operations_latency_microseconds%22%2C%0A%20%20%22operations_errors%22%2C%0A%20%20%22image_pulls_layer_size%22%2C%0A%20%20%22containers_oom_total%22%2C%0A%20%20%22containers_oom%22%2C%0A%20%20%23%20Drop%20metrics%20with%20excessive%20label%20cardinality.%0A%20%20%23%20%22image_pulls_by_digest%22%2C%0A%20%20%23%20%22image_pulls_by_name%22%2C%0A%20%20%23%20%22image_pulls_by_name_skipped%22%2C%0A%20%20%23%20%22image_pulls_failures%22%2C%0A%20%20%23%20%22image_pulls_successes%22%2C%0A%20%20%23%20%22image_layer_reuse%22%2C%0A%5D%0A"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/crio/crio.conf.d/00-default"
                            },
                            {
                                "contents": {
                                    "source": "data:,%7B%0A%20%20%20%20%22default%22%3A%20%5B%0A%20%20%20%20%20%20%20%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%22type%22%3A%20%22insecureAcceptAnything%22%0A%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%5D%2C%0A%20%20%20%20%22transports%22%3A%0A%20%20%20%20%20%20%20%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%22docker-daemon%22%3A%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%22%22%3A%20%5B%7B%22type%22%3A%22insecureAcceptAnything%22%7D%5D%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%7D%0A%7D"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/containers/policy.json"
                            }
                        ]
                    }
                },
                "extensions": null,
                "fips": false,
                "kernelArguments": null,
                "kernelType": "",
                "osImageURL": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:ac2ad5b01eed7b0222dabbfb5c6d4b19ddc85bdaab66738f7ff620e4acffb6ac"
            }
        },
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfig",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/generated-by-controller-version": "33286190af0d4d340af5c61e603d185780e74b39"
                },
                "creationTimestamp": "2021-11-03T13:39:52Z",
                "generation": 1,
                "labels": {
                    "machineconfiguration.openshift.io/role": "master"
                },
                "name": "01-master-kubelet",
                "ownerReferences": [
                    {
                        "apiVersion": "machineconfiguration.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "ControllerConfig",
                        "name": "machine-config-controller",
                        "uid": "04e946af-d1a0-4b73-9092-9e787fa55070"
                    }
                ],
                "resourceVersion": "8063",
                "uid": "308de1b4-1be5-406c-9781-24c2c8d0addc"
            },
            "spec": {
                "config": {
                    "ignition": {
                        "version": "3.2.0"
                    },
                    "storage": {
                        "files": [
                            {
                                "contents": {
                                    "source": "data:,"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/kubernetes/cloud.conf"
                            },
                            {
                                "contents": {
                                    "source": "data:,kind%3A%20KubeletConfiguration%0AapiVersion%3A%20kubelet.config.k8s.io%2Fv1beta1%0Aauthentication%3A%0A%20%20x509%3A%0A%20%20%20%20clientCAFile%3A%20%2Fetc%2Fkubernetes%2Fkubelet-ca.crt%0A%20%20anonymous%3A%0A%20%20%20%20enabled%3A%20false%0AcgroupDriver%3A%20systemd%0AcgroupRoot%3A%20%2F%0AclusterDNS%3A%0A%20%20-%20172.30.0.10%0AclusterDomain%3A%20cluster.local%0AcontainerLogMaxSize%3A%2050Mi%0AmaxPods%3A%20250%0AkubeAPIQPS%3A%2050%0AkubeAPIBurst%3A%20100%0ArotateCertificates%3A%20true%0AserializeImagePulls%3A%20false%0AstaticPodPath%3A%20%2Fetc%2Fkubernetes%2Fmanifests%0AsystemCgroups%3A%20%2Fsystem.slice%0AsystemReserved%3A%0A%20%20ephemeral-storage%3A%201Gi%0AfeatureGates%3A%0A%20%20APIPriorityAndFairness%3A%20true%0A%20%20LegacyNodeRoleBehavior%3A%20false%0A%20%20NodeDisruptionExclusion%3A%20true%0A%20%20RotateKubeletServerCertificate%3A%20true%0A%20%20ServiceNodeExclusion%3A%20true%0A%20%20SupportPodPidsLimit%3A%20true%0A%20%20DownwardAPIHugePages%3A%20true%0AserverTLSBootstrap%3A%20true%0AtlsMinVersion%3A%20VersionTLS12%0AtlsCipherSuites%3A%0A%20%20-%20TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256%0A%20%20-%20TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256%0A%20%20-%20TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384%0A%20%20-%20TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384%0A%20%20-%20TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256%0A%20%20-%20TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256%0A"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/kubernetes/kubelet.conf"
                            }
                        ]
                    },
                    "systemd": {
                        "units": [
                            {
                                "contents": "[Unit]\nDescription=Kubernetes Kubelet\nWants=rpc-statd.service network-online.target\nRequires=crio.service kubelet-auto-node-size.service\nAfter=network-online.target crio.service kubelet-auto-node-size.service\nAfter=ostree-finalize-staged.service\n\n[Service]\nType=notify\nExecStartPre=/bin/mkdir --parents /etc/kubernetes/manifests\nExecStartPre=/bin/rm -f /var/lib/kubelet/cpu_manager_state\nExecStartPre=/bin/rm -f /var/lib/kubelet/memory_manager_state\nEnvironmentFile=/etc/os-release\nEnvironmentFile=-/etc/kubernetes/kubelet-workaround\nEnvironmentFile=-/etc/kubernetes/kubelet-env\nEnvironmentFile=/etc/node-sizing.env\n\nExecStart=/usr/bin/hyperkube \\\n    kubelet \\\n      --config=/etc/kubernetes/kubelet.conf \\\n      --bootstrap-kubeconfig=/etc/kubernetes/kubeconfig \\\n      --kubeconfig=/var/lib/kubelet/kubeconfig \\\n      --container-runtime=remote \\\n      --container-runtime-endpoint=/var/run/crio/crio.sock \\\n      --runtime-cgroups=/system.slice/crio.service \\\n      --node-labels=node-role.kubernetes.io/master,node.openshift.io/os_id=${ID} \\\n      --node-ip=${KUBELET_NODE_IP} \\\n      --minimum-container-ttl-duration=6m0s \\\n      --cloud-provider=aws \\\n      --volume-plugin-dir=/etc/kubernetes/kubelet-plugins/volume/exec \\\n       \\\n      --hostname-override=${KUBELET_NODE_NAME} \\\n      --register-with-taints=node-role.kubernetes.io/master=:NoSchedule \\\n      --pod-infra-container-image=quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:e73dbbf5048f53d65303d1e80cb588b70813d6cd91654c292998c1dba558bf14 \\\n      --system-reserved=cpu=${SYSTEM_RESERVED_CPU},memory=${SYSTEM_RESERVED_MEMORY} \\\n      --v=${KUBELET_LOG_LEVEL}\n\nRestart=always\nRestartSec=10\n\n[Install]\nWantedBy=multi-user.target\n",
                                "enabled": true,
                                "name": "kubelet.service"
                            }
                        ]
                    }
                },
                "extensions": null,
                "fips": false,
                "kernelArguments": null,
                "kernelType": "",
                "osImageURL": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:ac2ad5b01eed7b0222dabbfb5c6d4b19ddc85bdaab66738f7ff620e4acffb6ac"
            }
        },
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfig",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/generated-by-controller-version": "33286190af0d4d340af5c61e603d185780e74b39"
                },
                "creationTimestamp": "2021-11-03T13:39:52Z",
                "generation": 1,
                "labels": {
                    "machineconfiguration.openshift.io/role": "worker"
                },
                "name": "01-worker-container-runtime",
                "ownerReferences": [
                    {
                        "apiVersion": "machineconfiguration.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "ControllerConfig",
                        "name": "machine-config-controller",
                        "uid": "04e946af-d1a0-4b73-9092-9e787fa55070"
                    }
                ],
                "resourceVersion": "8064",
                "uid": "623aaa44-225e-4e5f-b64f-5aae6aabd849"
            },
            "spec": {
                "config": {
                    "ignition": {
                        "version": "3.2.0"
                    },
                    "storage": {
                        "files": [
                            {
                                "contents": {
                                    "source": "data:,unqualified-search-registries%20%3D%20%5B'registry.access.redhat.com'%2C%20'docker.io'%5D%0A"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/containers/registries.conf"
                            },
                            {
                                "contents": {
                                    "source": "data:,%5Bcrio%5D%0Ainternal_wipe%20%3D%20true%0Astorage_driver%20%3D%20%22overlay%22%0Astorage_option%20%3D%20%5B%0A%20%20%20%20%22overlay.override_kernel_check%3D1%22%2C%0A%5D%0A%0A%5Bcrio.api%5D%0Astream_address%20%3D%20%22%22%0Astream_port%20%3D%20%2210010%22%0A%0A%5Bcrio.runtime%5D%0Aselinux%20%3D%20true%0Aconmon%20%3D%20%22%22%0Aconmon_cgroup%20%3D%20%22pod%22%0Adefault_env%20%3D%20%5B%0A%20%20%20%20%22NSS_SDB_USE_CACHE%3Dno%22%2C%0A%5D%0Alog_level%20%3D%20%22info%22%0Acgroup_manager%20%3D%20%22systemd%22%0Adefault_sysctls%20%3D%20%5B%0A%20%20%20%20%22net.ipv4.ping_group_range%3D0%202147483647%22%2C%0A%5D%0Ahooks_dir%20%3D%20%5B%0A%20%20%20%20%22%2Fetc%2Fcontainers%2Foci%2Fhooks.d%22%2C%0A%20%20%20%20%22%2Frun%2Fcontainers%2Foci%2Fhooks.d%22%2C%0A%5D%0Amanage_ns_lifecycle%20%3D%20true%0Aabsent_mount_sources_to_reject%20%3D%20%5B%0A%20%20%20%20%22%2Fetc%2Fhostname%22%2C%0A%5D%0Adrop_infra_ctr%20%3D%20true%0A%0A%5Bcrio.image%5D%0Aglobal_auth_file%20%3D%20%22%2Fvar%2Flib%2Fkubelet%2Fconfig.json%22%0Apause_image%20%3D%20%22quay.io%2Fopenshift-release-dev%2Focp-v4.0-art-dev%40sha256%3Ae73dbbf5048f53d65303d1e80cb588b70813d6cd91654c292998c1dba558bf14%22%0Apause_image_auth_file%20%3D%20%22%2Fvar%2Flib%2Fkubelet%2Fconfig.json%22%0Apause_command%20%3D%20%22%2Fusr%2Fbin%2Fpod%22%0A%0A%5Bcrio.network%5D%0Anetwork_dir%20%3D%20%22%2Fetc%2Fkubernetes%2Fcni%2Fnet.d%2F%22%0Aplugin_dirs%20%3D%20%5B%0A%20%20%20%20%22%2Fvar%2Flib%2Fcni%2Fbin%22%2C%0A%20%20%20%20%22%2Fusr%2Flibexec%2Fcni%22%2C%0A%5D%0A%0A%5Bcrio.metrics%5D%0Aenable_metrics%20%3D%20true%0Ametrics_port%20%3D%209537%0Ametrics_collectors%20%3D%20%5B%0A%20%20%22operations%22%2C%0A%20%20%22operations_latency_microseconds_total%22%2C%0A%20%20%22operations_latency_microseconds%22%2C%0A%20%20%22operations_errors%22%2C%0A%20%20%22image_pulls_layer_size%22%2C%0A%20%20%22containers_oom_total%22%2C%0A%20%20%22containers_oom%22%2C%0A%20%20%23%20Drop%20metrics%20with%20excessive%20label%20cardinality.%0A%20%20%23%20%22image_pulls_by_digest%22%2C%0A%20%20%23%20%22image_pulls_by_name%22%2C%0A%20%20%23%20%22image_pulls_by_name_skipped%22%2C%0A%20%20%23%20%22image_pulls_failures%22%2C%0A%20%20%23%20%22image_pulls_successes%22%2C%0A%20%20%23%20%22image_layer_reuse%22%2C%0A%5D%0A"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/crio/crio.conf.d/00-default"
                            },
                            {
                                "contents": {
                                    "source": "data:,%7B%0A%20%20%20%20%22default%22%3A%20%5B%0A%20%20%20%20%20%20%20%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%22type%22%3A%20%22insecureAcceptAnything%22%0A%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%5D%2C%0A%20%20%20%20%22transports%22%3A%0A%20%20%20%20%20%20%20%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%22docker-daemon%22%3A%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%22%22%3A%20%5B%7B%22type%22%3A%22insecureAcceptAnything%22%7D%5D%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%7D%0A%7D"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/containers/policy.json"
                            }
                        ]
                    }
                },
                "extensions": null,
                "fips": false,
                "kernelArguments": null,
                "kernelType": "",
                "osImageURL": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:ac2ad5b01eed7b0222dabbfb5c6d4b19ddc85bdaab66738f7ff620e4acffb6ac"
            }
        },
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfig",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/generated-by-controller-version": "33286190af0d4d340af5c61e603d185780e74b39"
                },
                "creationTimestamp": "2021-11-03T13:39:52Z",
                "generation": 1,
                "labels": {
                    "machineconfiguration.openshift.io/role": "worker"
                },
                "name": "01-worker-kubelet",
                "ownerReferences": [
                    {
                        "apiVersion": "machineconfiguration.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "ControllerConfig",
                        "name": "machine-config-controller",
                        "uid": "04e946af-d1a0-4b73-9092-9e787fa55070"
                    }
                ],
                "resourceVersion": "8096",
                "uid": "080cc6d5-df83-4819-8e4e-a267145b6787"
            },
            "spec": {
                "config": {
                    "ignition": {
                        "version": "3.2.0"
                    },
                    "storage": {
                        "files": [
                            {
                                "contents": {
                                    "source": "data:,"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/kubernetes/cloud.conf"
                            },
                            {
                                "contents": {
                                    "source": "data:,kind%3A%20KubeletConfiguration%0AapiVersion%3A%20kubelet.config.k8s.io%2Fv1beta1%0Aauthentication%3A%0A%20%20x509%3A%0A%20%20%20%20clientCAFile%3A%20%2Fetc%2Fkubernetes%2Fkubelet-ca.crt%0A%20%20anonymous%3A%0A%20%20%20%20enabled%3A%20false%0AcgroupDriver%3A%20systemd%0AcgroupRoot%3A%20%2F%0AclusterDNS%3A%0A%20%20-%20172.30.0.10%0AclusterDomain%3A%20cluster.local%0AcontainerLogMaxSize%3A%2050Mi%0AmaxPods%3A%20250%0AkubeAPIQPS%3A%2050%0AkubeAPIBurst%3A%20100%0ArotateCertificates%3A%20true%0AserializeImagePulls%3A%20false%0AstaticPodPath%3A%20%2Fetc%2Fkubernetes%2Fmanifests%0AsystemCgroups%3A%20%2Fsystem.slice%0AsystemReserved%3A%0A%20%20ephemeral-storage%3A%201Gi%0AfeatureGates%3A%0A%20%20APIPriorityAndFairness%3A%20true%0A%20%20LegacyNodeRoleBehavior%3A%20false%0A%20%20NodeDisruptionExclusion%3A%20true%0A%20%20RotateKubeletServerCertificate%3A%20true%0A%20%20ServiceNodeExclusion%3A%20true%0A%20%20SupportPodPidsLimit%3A%20true%0A%20%20DownwardAPIHugePages%3A%20true%0AserverTLSBootstrap%3A%20true%0AtlsMinVersion%3A%20VersionTLS12%0AtlsCipherSuites%3A%0A%20%20-%20TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256%0A%20%20-%20TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256%0A%20%20-%20TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384%0A%20%20-%20TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384%0A%20%20-%20TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256%0A%20%20-%20TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256%0A"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/kubernetes/kubelet.conf"
                            }
                        ]
                    },
                    "systemd": {
                        "units": [
                            {
                                "contents": "[Unit]\nDescription=Kubernetes Kubelet\nWants=rpc-statd.service network-online.target\nRequires=crio.service kubelet-auto-node-size.service\nAfter=network-online.target crio.service kubelet-auto-node-size.service\nAfter=ostree-finalize-staged.service\n\n[Service]\nType=notify\nExecStartPre=/bin/mkdir --parents /etc/kubernetes/manifests\nExecStartPre=/bin/rm -f /var/lib/kubelet/cpu_manager_state\nExecStartPre=/bin/rm -f /var/lib/kubelet/memory_manager_state\nEnvironmentFile=/etc/os-release\nEnvironmentFile=-/etc/kubernetes/kubelet-workaround\nEnvironmentFile=-/etc/kubernetes/kubelet-env\nEnvironmentFile=/etc/node-sizing.env\n\nExecStart=/usr/bin/hyperkube \\\n    kubelet \\\n      --config=/etc/kubernetes/kubelet.conf \\\n      --bootstrap-kubeconfig=/etc/kubernetes/kubeconfig \\\n      --kubeconfig=/var/lib/kubelet/kubeconfig \\\n      --container-runtime=remote \\\n      --container-runtime-endpoint=/var/run/crio/crio.sock \\\n      --runtime-cgroups=/system.slice/crio.service \\\n      --node-labels=node-role.kubernetes.io/worker,node.openshift.io/os_id=${ID} \\\n      --node-ip=${KUBELET_NODE_IP} \\\n      --minimum-container-ttl-duration=6m0s \\\n      --volume-plugin-dir=/etc/kubernetes/kubelet-plugins/volume/exec \\\n      --cloud-provider=aws \\\n       \\\n      --hostname-override=${KUBELET_NODE_NAME} \\\n      --pod-infra-container-image=quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:e73dbbf5048f53d65303d1e80cb588b70813d6cd91654c292998c1dba558bf14 \\\n      --system-reserved=cpu=${SYSTEM_RESERVED_CPU},memory=${SYSTEM_RESERVED_MEMORY} \\\n      --v=${KUBELET_LOG_LEVEL}\n\nRestart=always\nRestartSec=10\n\n[Install]\nWantedBy=multi-user.target\n",
                                "enabled": true,
                                "name": "kubelet.service"
                            }
                        ]
                    }
                },
                "extensions": null,
                "fips": false,
                "kernelArguments": null,
                "kernelType": "",
                "osImageURL": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:ac2ad5b01eed7b0222dabbfb5c6d4b19ddc85bdaab66738f7ff620e4acffb6ac"
            }
        },
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfig",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/generated-by-controller-version": "33286190af0d4d340af5c61e603d185780e74b39"
                },
                "creationTimestamp": "2021-11-03T13:39:52Z",
                "generation": 1,
                "labels": {
                    "machineconfiguration.openshift.io/role": "master"
                },
                "name": "99-master-generated-registries",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "Image",
                        "name": "cluster",
                        "uid": "4485d46b-0c92-432c-b08a-f32776905a0d"
                    }
                ],
                "resourceVersion": "8094",
                "uid": "d66ef4bc-1ecf-479c-be1e-824fb9c229fd"
            },
            "spec": {
                "config": {
                    "ignition": {
                        "version": "3.2.0"
                    }
                },
                "extensions": null,
                "fips": false,
                "kernelArguments": null,
                "kernelType": "",
                "osImageURL": ""
            }
        },
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfig",
            "metadata": {
                "creationTimestamp": "2021-11-03T13:37:01Z",
                "generation": 1,
                "labels": {
                    "machineconfiguration.openshift.io/role": "master"
                },
                "name": "99-master-ssh",
                "resourceVersion": "1563",
                "uid": "c21b9895-1cf4-41e9-a744-dbe89da5d0e8"
            },
            "spec": {
                "config": {
                    "ignition": {
                        "version": "3.2.0"
                    },
                    "passwd": {
                        "users": [
                            {
                                "name": "core",
                                "sshAuthorizedKeys": [
                                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbXCby9r69mn+lGn7/mjZRkr+ShGWmVcXT4pbwA8IJBkjJg/EtXFuL1VjP5QbbWvjakQ1ZpMEYkL4V1Gm1etzkoDuMV+VhvvL8uW59XezLH1My9RQ5vtXY7GpB3t4qbTX2AQ5abAlTAoRgOxr5mKT62m3uUpU6HBWkcqwhNGRNPQOhUBybbpxMyakJ/TyS5F7GOajsCWdhx3ErldXrtUgbArPwR16Nh0lA3jO81QJnKzbkcaVlCNd8A3to0Dx1g5cel2HDK37Ri6xYZssh1qGN+fecc7Gf4lqvp1gGMtKMyZw8t54/cJrSeVhzi+mq8aeTIaOAwpoa8C4H80HE35wog1tsS0WALlPdNZ8IyPZRfhH3iG12X0WttB5x2hHngQaYzSWzs1TvEGwrci1Y8EFE1xXG6ArAPG5Iy79tmXlOZM/R/D1K6oVRrVB6T4fWKtHFHJExlRI6HWT+Qxye96RPWxEdKEhWzOLRrBiWPSXYCtT4SCbBirP4C/htnDNcMGlT/HIETVf0R+ixjnsqeYYQn15cXvWSSDQ4LTnW9vBrDLsWVFV8hJ4outZ67Ztf/tBuGKfUFzLkTCFhWJER1bbH7Zhxn5xCplI4REr2+PKnhRaPCrz6W2TRO94pACkJG3M4eP3OyCbVfC1N1c0+MPwwJ0R7TAllli94t5jQthu8xw==\n"
                                ]
                            }
                        ]
                    }
                },
                "extensions": null,
                "fips": false,
                "kernelArguments": null,
                "kernelType": "",
                "osImageURL": ""
            }
        },
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfig",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/generated-by-controller-version": "33286190af0d4d340af5c61e603d185780e74b39"
                },
                "creationTimestamp": "2021-11-03T13:39:52Z",
                "generation": 1,
                "labels": {
                    "machineconfiguration.openshift.io/role": "worker"
                },
                "name": "99-worker-generated-registries",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "Image",
                        "name": "cluster",
                        "uid": "4485d46b-0c92-432c-b08a-f32776905a0d"
                    }
                ],
                "resourceVersion": "8086",
                "uid": "4acea6e2-9562-4b21-9d6c-d76ed9deb567"
            },
            "spec": {
                "config": {
                    "ignition": {
                        "version": "3.2.0"
                    }
                },
                "extensions": null,
                "fips": false,
                "kernelArguments": null,
                "kernelType": "",
                "osImageURL": ""
            }
        },
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfig",
            "metadata": {
                "creationTimestamp": "2021-11-03T13:37:01Z",
                "generation": 1,
                "labels": {
                    "machineconfiguration.openshift.io/role": "worker"
                },
                "name": "99-worker-ssh",
                "resourceVersion": "1582",
                "uid": "b5f3c8c6-3163-4a46-acb8-29e534cb33fb"
            },
            "spec": {
                "config": {
                    "ignition": {
                        "version": "3.2.0"
                    },
                    "passwd": {
                        "users": [
                            {
                                "name": "core",
                                "sshAuthorizedKeys": [
                                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbXCby9r69mn+lGn7/mjZRkr+ShGWmVcXT4pbwA8IJBkjJg/EtXFuL1VjP5QbbWvjakQ1ZpMEYkL4V1Gm1etzkoDuMV+VhvvL8uW59XezLH1My9RQ5vtXY7GpB3t4qbTX2AQ5abAlTAoRgOxr5mKT62m3uUpU6HBWkcqwhNGRNPQOhUBybbpxMyakJ/TyS5F7GOajsCWdhx3ErldXrtUgbArPwR16Nh0lA3jO81QJnKzbkcaVlCNd8A3to0Dx1g5cel2HDK37Ri6xYZssh1qGN+fecc7Gf4lqvp1gGMtKMyZw8t54/cJrSeVhzi+mq8aeTIaOAwpoa8C4H80HE35wog1tsS0WALlPdNZ8IyPZRfhH3iG12X0WttB5x2hHngQaYzSWzs1TvEGwrci1Y8EFE1xXG6ArAPG5Iy79tmXlOZM/R/D1K6oVRrVB6T4fWKtHFHJExlRI6HWT+Qxye96RPWxEdKEhWzOLRrBiWPSXYCtT4SCbBirP4C/htnDNcMGlT/HIETVf0R+ixjnsqeYYQn15cXvWSSDQ4LTnW9vBrDLsWVFV8hJ4outZ67Ztf/tBuGKfUFzLkTCFhWJER1bbH7Zhxn5xCplI4REr2+PKnhRaPCrz6W2TRO94pACkJG3M4eP3OyCbVfC1N1c0+MPwwJ0R7TAllli94t5jQthu8xw==\n"
                                ]
                            }
                        ]
                    }
                },
                "extensions": null,
                "fips": false,
                "kernelArguments": null,
                "kernelType": "",
                "osImageURL": ""
            }
        },
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfig",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/generated-by-controller-version": "33286190af0d4d340af5c61e603d185780e74b39"
                },
                "creationTimestamp": "2021-11-03T13:39:55Z",
                "generation": 1,
                "name": "rendered-master-e15120ebc22068625d73460e51d21e41",
                "ownerReferences": [
                    {
                        "apiVersion": "machineconfiguration.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "MachineConfigPool",
                        "name": "master",
                        "uid": "a406ab12-6edc-4973-bbb5-a9fc0c696d3b"
                    }
                ],
                "resourceVersion": "8242",
                "uid": "d98da071-a803-443b-9db2-4656bfe80a30"
            },
            "spec": {
                "config": {
                    "ignition": {
                        "version": "3.2.0"
                    },
                    "passwd": {
                        "users": [
                            {
                                "name": "core",
                                "sshAuthorizedKeys": [
                                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbXCby9r69mn+lGn7/mjZRkr+ShGWmVcXT4pbwA8IJBkjJg/EtXFuL1VjP5QbbWvjakQ1ZpMEYkL4V1Gm1etzkoDuMV+VhvvL8uW59XezLH1My9RQ5vtXY7GpB3t4qbTX2AQ5abAlTAoRgOxr5mKT62m3uUpU6HBWkcqwhNGRNPQOhUBybbpxMyakJ/TyS5F7GOajsCWdhx3ErldXrtUgbArPwR16Nh0lA3jO81QJnKzbkcaVlCNd8A3to0Dx1g5cel2HDK37Ri6xYZssh1qGN+fecc7Gf4lqvp1gGMtKMyZw8t54/cJrSeVhzi+mq8aeTIaOAwpoa8C4H80HE35wog1tsS0WALlPdNZ8IyPZRfhH3iG12X0WttB5x2hHngQaYzSWzs1TvEGwrci1Y8EFE1xXG6ArAPG5Iy79tmXlOZM/R/D1K6oVRrVB6T4fWKtHFHJExlRI6HWT+Qxye96RPWxEdKEhWzOLRrBiWPSXYCtT4SCbBirP4C/htnDNcMGlT/HIETVf0R+ixjnsqeYYQn15cXvWSSDQ4LTnW9vBrDLsWVFV8hJ4outZ67Ztf/tBuGKfUFzLkTCFhWJER1bbH7Zhxn5xCplI4REr2+PKnhRaPCrz6W2TRO94pACkJG3M4eP3OyCbVfC1N1c0+MPwwJ0R7TAllli94t5jQthu8xw==\n"
                                ]
                            }
                        ]
                    },
                    "storage": {
                        "files": [
                            {
                                "contents": {
                                    "source": "data:,kind%3A%20KubeletConfiguration%0AapiVersion%3A%20kubelet.config.k8s.io%2Fv1beta1%0Aauthentication%3A%0A%20%20x509%3A%0A%20%20%20%20clientCAFile%3A%20%2Fetc%2Fkubernetes%2Fkubelet-ca.crt%0A%20%20anonymous%3A%0A%20%20%20%20enabled%3A%20false%0AcgroupDriver%3A%20systemd%0AcgroupRoot%3A%20%2F%0AclusterDNS%3A%0A%20%20-%20172.30.0.10%0AclusterDomain%3A%20cluster.local%0AcontainerLogMaxSize%3A%2050Mi%0AmaxPods%3A%20250%0AkubeAPIQPS%3A%2050%0AkubeAPIBurst%3A%20100%0ArotateCertificates%3A%20true%0AserializeImagePulls%3A%20false%0AstaticPodPath%3A%20%2Fetc%2Fkubernetes%2Fmanifests%0AsystemCgroups%3A%20%2Fsystem.slice%0AsystemReserved%3A%0A%20%20ephemeral-storage%3A%201Gi%0AfeatureGates%3A%0A%20%20APIPriorityAndFairness%3A%20true%0A%20%20LegacyNodeRoleBehavior%3A%20false%0A%20%20NodeDisruptionExclusion%3A%20true%0A%20%20RotateKubeletServerCertificate%3A%20true%0A%20%20ServiceNodeExclusion%3A%20true%0A%20%20SupportPodPidsLimit%3A%20true%0A%20%20DownwardAPIHugePages%3A%20true%0AserverTLSBootstrap%3A%20true%0AtlsMinVersion%3A%20VersionTLS12%0AtlsCipherSuites%3A%0A%20%20-%20TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256%0A%20%20-%20TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256%0A%20%20-%20TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384%0A%20%20-%20TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384%0A%20%20-%20TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256%0A%20%20-%20TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256%0A"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/kubernetes/kubelet.conf"
                            }
                        ]
                    },
                    "systemd": {
                        "units": [
                            {
                                "contents": "[Unit]\nDescription=Fetch kubelet node name from AWS Metadata\n# Wait for NetworkManager to report it's online\nAfter=NetworkManager-wait-online.service\n# Run before kubelet\nBefore=kubelet.service\n\n[Service]\nExecStart=/usr/local/bin/aws-kubelet-nodename\nType=oneshot\n\n[Install]\nWantedBy=network-online.target\n",
                                "enabled": true,
                                "name": "aws-kubelet-nodename.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "",
                                        "name": "10-mco-default-env.conf"
                                    },
                                    {
                                        "contents": "[Service]\nEnvironment=\"ENABLE_PROFILE_UNIX_SOCKET=true\"\n",
                                        "name": "10-mco-profile-unix-socket.conf"
                                    },
                                    {
                                        "contents": "[Service]\nEnvironment=\"GODEBUG=x509ignoreCN=0,madvdontneed=1\"\n",
                                        "name": "10-mco-default-madv.conf"
                                    }
                                ],
                                "name": "crio.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "[Unit]\nConditionPathExists=/enoent\n",
                                        "name": "mco-disabled.conf"
                                    }
                                ],
                                "name": "docker.socket"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "[Unit]\nConditionPathExists=/enoent\n",
                                        "name": "mco-disabled.conf"
                                    }
                                ],
                                "name": "zincati.service"
                            }
                        ]
                    }
                },
                "extensions": [],
                "fips": false,
                "kernelArguments": [],
                "kernelType": "default",
                "osImageURL": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:ac2ad5b01eed7b0222dabbfb5c6d4b19ddc85bdaab66738f7ff620e4acffb6ac"
            }
        },
        {
            "apiVersion": "machineconfiguration.openshift.io/v1",
            "kind": "MachineConfig",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/generated-by-controller-version": "33286190af0d4d340af5c61e603d185780e74b39"
                },
                "creationTimestamp": "2021-11-03T13:39:55Z",
                "generation": 1,
                "name": "rendered-worker-d2a9e15a1284e0e14a198a508019a1f3",
                "ownerReferences": [
                    {
                        "apiVersion": "machineconfiguration.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "MachineConfigPool",
                        "name": "worker",
                        "uid": "29557569-ea0d-4d48-b112-953733851629"
                    }
                ],
                "resourceVersion": "8241",
                "uid": "c12a07f4-35a0-43af-83dd-fa0fa9869ca7"
            },
            "spec": {
                "config": {
                    "ignition": {
                        "version": "3.2.0"
                    },
                    "passwd": {
                        "users": [
                            {
                                "name": "core",
                                "sshAuthorizedKeys": [
                                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbXCby9r69mn+lGn7/mjZRkr+ShGWmVcXT4pbwA8IJBkjJg/EtXFuL1VjP5QbbWvjakQ1ZpMEYkL4V1Gm1etzkoDuMV+VhvvL8uW59XezLH1My9RQ5vtXY7GpB3t4qbTX2AQ5abAlTAoRgOxr5mKT62m3uUpU6HBWkcqwhNGRNPQOhUBybbpxMyakJ/TyS5F7GOajsCWdhx3ErldXrtUgbArPwR16Nh0lA3jO81QJnKzbkcaVlCNd8A3to0Dx1g5cel2HDK37Ri6xYZssh1qGN+fecc7Gf4lqvp1gGMtKMyZw8t54/cJrSeVhzi+mq8aeTIaOAwpoa8C4H80HE35wog1tsS0WALlPdNZ8IyPZRfhH3iG12X0WttB5x2hHngQaYzSWzs1TvEGwrci1Y8EFE1xXG6ArAPG5Iy79tmXlOZM/R/D1K6oVRrVB6T4fWKtHFHJExlRI6HWT+Qxye96RPWxEdKEhWzOLRrBiWPSXYCtT4SCbBirP4C/htnDNcMGlT/HIETVf0R+ixjnsqeYYQn15cXvWSSDQ4LTnW9vBrDLsWVFV8hJ4outZ67Ztf/tBuGKfUFzLkTCFhWJER1bbH7Zhxn5xCplI4REr2+PKnhRaPCrz6W2TRO94pACkJG3M4eP3OyCbVfC1N1c0+MPwwJ0R7TAllli94t5jQthu8xw==\n"
                                ]
                            }
                        ]
                    },
                    "storage": {
                        "files": [                            
                            {
                                "contents": {
                                    "source": "data:,kind%3A%20KubeletConfiguration%0AapiVersion%3A%20kubelet.config.k8s.io%2Fv1beta1%0Aauthentication%3A%0A%20%20x509%3A%0A%20%20%20%20clientCAFile%3A%20%2Fetc%2Fkubernetes%2Fkubelet-ca.crt%0A%20%20anonymous%3A%0A%20%20%20%20enabled%3A%20false%0AcgroupDriver%3A%20systemd%0AcgroupRoot%3A%20%2F%0AclusterDNS%3A%0A%20%20-%20172.30.0.10%0AclusterDomain%3A%20cluster.local%0AcontainerLogMaxSize%3A%2050Mi%0AmaxPods%3A%20250%0AkubeAPIQPS%3A%2050%0AkubeAPIBurst%3A%20100%0ArotateCertificates%3A%20true%0AserializeImagePulls%3A%20false%0AstaticPodPath%3A%20%2Fetc%2Fkubernetes%2Fmanifests%0AsystemCgroups%3A%20%2Fsystem.slice%0AsystemReserved%3A%0A%20%20ephemeral-storage%3A%201Gi%0AfeatureGates%3A%0A%20%20APIPriorityAndFairness%3A%20true%0A%20%20LegacyNodeRoleBehavior%3A%20false%0A%20%20NodeDisruptionExclusion%3A%20true%0A%20%20RotateKubeletServerCertificate%3A%20true%0A%20%20ServiceNodeExclusion%3A%20true%0A%20%20SupportPodPidsLimit%3A%20true%0A%20%20DownwardAPIHugePages%3A%20true%0AserverTLSBootstrap%3A%20true%0AtlsMinVersion%3A%20VersionTLS12%0AtlsCipherSuites%3A%0A%20%20-%20TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256%0A%20%20-%20TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256%0A%20%20-%20TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384%0A%20%20-%20TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384%0A%20%20-%20TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256%0A%20%20-%20TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256%0A"
                                },
                                "mode": 420,
                                "overwrite": true,
                                "path": "/etc/kubernetes/kubelet.conf"
                            }
                        ]
                    },
                    "systemd": {
                        "units": [
                            {
                                "contents": "[Unit]\nDescription=Fetch kubelet node name from AWS Metadata\n# Wait for NetworkManager to report it's online\nAfter=NetworkManager-wait-online.service\n# Run before kubelet\nBefore=kubelet.service\n\n[Service]\nExecStart=/usr/local/bin/aws-kubelet-nodename\nType=oneshot\n\n[Install]\nWantedBy=network-online.target\n",
                                "enabled": true,
                                "name": "aws-kubelet-nodename.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "",
                                        "name": "10-mco-default-env.conf"
                                    },
                                    {
                                        "contents": "[Service]\nEnvironment=\"ENABLE_PROFILE_UNIX_SOCKET=true\"\n",
                                        "name": "10-mco-profile-unix-socket.conf"
                                    },
                                    {
                                        "contents": "[Service]\nEnvironment=\"GODEBUG=x509ignoreCN=0,madvdontneed=1\"\n",
                                        "name": "10-mco-default-madv.conf"
                                    }
                                ],
                                "name": "crio.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "[Unit]\nConditionPathExists=/enoent\n",
                                        "name": "mco-disabled.conf"
                                    }
                                ],
                                "name": "docker.socket"
                            },
                            {
                                "contents": "[Unit]\nDescription=Dynamically sets the system reserved for the kubelet\nWants=network-online.target\nAfter=network-online.target ignition-firstboot-complete.service\nBefore=kubelet.service crio.service\n[Service]\n# Need oneshot to delay kubelet\nType=oneshot\nRemainAfterExit=yes\nEnvironmentFile=/etc/node-sizing-enabled.env\nExecStart=/bin/bash /usr/local/sbin/dynamic-system-reserved-calc.sh ${NODE_SIZING_ENABLED} ${SYSTEM_RESERVED_MEMORY} ${SYSTEM_RESERVED_CPU}\n[Install]\nRequiredBy=kubelet.service\n",
                                "enabled": true,
                                "name": "kubelet-auto-node-size.service"
                            },
                            {
                                "dropins": [
                                    {
                                        "contents": "[Unit]\nConditionPathExists=/enoent\n",
                                        "name": "mco-disabled.conf"
                                    }
                                ],
                                "name": "zincati.service"
                            }
                        ]
                    }
                },
                "extensions": [],
                "fips": false,
                "kernelArguments": [],
                "kernelType": "default",
                "osImageURL": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:ac2ad5b01eed7b0222dabbfb5c6d4b19ddc85bdaab66738f7ff620e4acffb6ac"
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

jq_filter='[.items[] | select(.metadata.name | test("^rendered-worker-[0-9a-z]+$|^rendered-master-[0-9a-z]+$"))] | map(.spec.fips == true)'

# Get filtered path. This will actually be read by the scan
filteredpath="$kube_apipath/$machineconfig_apipath#$(echo -n "$machineconfig_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath/$machineconfig_apipath" 
jq "$jq_filter" "$kube_apipath/$machineconfig_apipath" > "$filteredpath"
