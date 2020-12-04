documentation_complete: true

title: 'CIS Red Hat OpenShift Container Platform 4 Benchmark'

platform: ocp4-node

metadata:
    SMEs:
        - JAORMX
        - mrogers950
        - jhrozek

description: |-
    This profile defines a baseline that aligns to the Center for Internet Security®
    Red Hat OpenShift Container Platform 4 Benchmark™, V0.3, currently unreleased.

    This profile includes Center for Internet Security®
    Red Hat OpenShift Container Platform 4 CIS Benchmarks™ content.

    Note that this part of the profile is meant to run on the Operating System that
    Red Hat OpenShift Container Platform 4 runs on top of.

    This profile is applicable to OpenShift versions 4.6 and greater.
selections:
  ### 1. Control Plane Components
  ###
  #### 1.1 Master Node Configuration Files
  # 1.1.1 Ensure that the API server pod specification file permissions are set to 644 or more restrictive
    - file_permissions_kube_apiserver
  # 1.1.2 Ensure that the API server pod specification file ownership is set to root:root
    - file_owner_kube_apiserver
    - file_groupowner_kube_apiserver
  # 1.1.3 Ensure that the controller manager pod specification file permissions are set to 644 or more restrictive
    - file_permissions_kube_controller_manager
  # 1.1.4 Ensure that the controller manager pod specification file ownership is set to root:root
    - file_owner_kube_controller_manager
    - file_groupowner_kube_controller_manager
  # 1.1.5 Ensure that the scheduler pod specification file permissions are set to 644 or more restrictive
    - file_permissions_scheduler
  # 1.1.6 Ensure that the scheduler pod specification file ownership is set to root:root
    - file_owner_kube_scheduler
    - file_groupowner_kube_scheduler
  # 1.1.7 Ensure that the etcd pod specification file permissions are set to 644 or more restrictive
    - file_permissions_etcd_member
  # 1.1.8 Ensure that the etcd pod specification file ownership is set to root:root (Automated)
    - file_owner_etcd_member
    - file_groupowner_etcd_member
  # 1.1.9 Ensure that the Container Network Interface file permissions are set to 644 or more restrictive
    - file_permissions_cni_conf
    - file_permissions_multus_conf
    - file_permissions_ip_allocations
    - file_perms_openshift_sdn_cniserver_config
    - file_permissions_ovs_pid
    - file_permissions_ovs_conf_db
    - file_permissions_ovs_sys_id_conf
    - file_permissions_ovs_conf_db_lock
    - file_permissions_ovs_vswitchd_pid
    - file_permissions_ovsdb_server_pid
  # 1.1.10 Ensure that the Container Network Interface file ownership is set to root:root
    - file_owner_cni_conf
    - file_groupowner_cni_conf
    - file_owner_multus_conf
    - file_groupowner_multus_conf
    - file_owner_ip_allocations
    - file_groupowner_ip_allocations
    - file_owner_openshift_sdn_cniserver_config
    - file_groupowner_openshift_sdn_cniserver_config
    - file_owner_ovs_pid
    - file_groupowner_ovs_pid
    - file_owner_ovs_conf_db
    - file_groupowner_ovs_conf_db
    - file_owner_ovs_sys_id_conf
    - file_groupowner_ovs_sys_id_conf
    - file_owner_ovs_conf_db_lock
    - file_groupowner_ovs_conf_db_lock
    - file_owner_ovs_vswitchd_pid
    - file_groupowner_ovs_vswitchd_pid
    - file_owner_ovsdb_server_pid
    - file_groupowner_ovsdb_server_pid
  # 1.1.11 Ensure that the etcd data directory permissions are set to 700 or more restrictive
    - file_permissions_etcd_data_dir
    - file_permissions_etcd_data_files
  # 1.1.12 Ensure that the etcd data directory ownership is set to root:root
    - file_owner_etcd_data_dir
    - file_groupowner_etcd_data_dir
    - file_owner_etcd_data_files
    - file_groupowner_etcd_data_files
  # 1.1.13 Ensure that the admin.conf file permissions are set to 644 or more restrictive
    - file_permissions_master_admin_kubeconfigs
  # 1.1.14 Ensure that the admin.conf file ownership is set to root:root 
    - file_owner_master_admin_kubeconfigs
    - file_groupowner_master_admin_kubeconfigs
  # 1.1.15 Ensure that the scheduler.conf file permissions are set to 644 or more restrictive
    - file_permissions_scheduler_kubeconfig
  # 1.1.16 Ensure that the scheduler.conf file ownership is set to root:root
    - file_owner_scheduler_kubeconfig
    - file_groupowner_scheduler_kubeconfig
  # 1.1.17 Ensure that the controller-manager.conf file permissions are set to 644 or more restrictive
    - file_permissions_controller_manager_kubeconfig
  # 1.1.18 Ensure that the controller-manager.conf file ownership is set to root:root 
    - file_owner_controller_manager_kubeconfig
    - file_groupowner_controller_manager_kubeconfig
  # 1.1.19 Ensure that the OpenShift PKI directory and file ownership is set to root:root
    - file_owner_openshift_pki_key_files
    - file_groupowner_openshift_pki_key_files
    - file_owner_openshift_pki_cert_files
    - file_groupowner_openshift_pki_cert_files
    - file_owner_etcd_pki_cert_files
    - file_groupowner_etcd_pki_cert_files
  # 1.1.20 Ensure that the OpenShift PKI certificate file permissions are set to 644 or more restrictive
    - file_permissions_openshift_pki_cert_files
    - file_permissions_etcd_pki_cert_files
  # 1.1.21 Ensure that the OpenShift PKI key file permissions are set to 600 
    - file_permissions_openshift_pki_key_files

  ### 2 etcd
  # 2.7 Ensure that a unique Certificate Authority is used for etcd
    - etcd_unique_ca

  ### 3 Control Plane Configuration
  ###
  #### 3.2 Logging
  # 3.2.1 Ensure that a minimal audit policy is created

  ### 4 Worker Nodes
  ###
  #### 4.1 Worker node configuration
  # 4.1.1 Ensure that the kubelet service file permissions are set to 644 or more restrictive
    - file_permissions_worker_service
  # 4.1.2 Ensure that the kubelet service file ownership is set to root:root
    - file_owner_worker_service
    - file_groupowner_worker_service
  # 4.1.5 Ensure that the --kubeconfig kubelet.conf file permissions are set to 644 or more restrictive
    - file_permissions_kubelet_conf
  # 4.1.6 Ensure that the --kubeconfig kubelet.conf file ownership is set to root:root
    - file_groupowner_kubelet_conf
    - file_owner_kubelet_conf
  # 4.1.7 Ensure that the certificate authorities file permissions are set to 644 or more restrictive
    - file_permissions_worker_ca
  # 4.1.8 Ensure that the client certificate authorities file ownership is set to root:root
    - file_owner_worker_ca
    - file_groupowner_worker_ca
  # 4.1.9 Ensure that the kubelet --config configuration file has permissions set to 644 or more restrictive
    - file_permissions_worker_kubeconfig
  # 4.1.10 Ensure that the kubelet configuration file ownership is set to root:root
    - file_owner_worker_kubeconfig
    - file_groupowner_worker_kubeconfig
  #### 4.2 Kubelet
  # 4.2.1 Ensure that the --anonymous-auth argument is set to false
    - kubelet_anonymous_auth
  # 4.2.2 Ensure that the --authorization-mode argument is not set to AlwaysAllow
    - kubelet_authorization_mode
  # 4.2.3 Ensure that the --client-ca-file argument is set as appropriate
    - kubelet_configure_client_ca
  # 4.2.5 Ensure that the --streaming-connection-idle-timeout argument is not set to 0
    - kubelet_enable_streaming_connections
  # 4.2.6 Ensure that the --protect-kernel-defaults argument is set to true
    #- kubelet_enable_protect_kernel_defaults
  # 4.2.7 Ensure that the --make-iptables-util-chains argument is set to true
    - kubelet_enable_iptables_util_chains
  # 4.2.8 Ensure that the --hostname-override argument is not set
    - kubelet_disable_hostname_override
  # 4.2.9 Ensure that the --event-qps argument is set to 0 or a level which ensures appropriate event capture
    - kubelet_configure_event_creation
  # 4.2.11 Ensure that the --rotate-certificates argument is not set to false
    - kubelet_enable_client_cert_rotation
    - kubelet_enable_cert_rotation
  # 4.2.12 Verify that the RotateKubeletServerCertificate argument is set to true
    - kubelet_enable_server_cert_rotation
