documentation_complete: false

title: 'CIS Red Hat OpenShift Container Platform 4 Benchmark'

description: |-
    This profile defines a baseline that aligns to the Center for Internet Security®
    Red Hat OpenShift Container Platform 4 Benchmark™, V0.3, currently unreleased.

    This profile includes Center for Internet Security®
    Red Hat OpenShift Container Platform 4 CIS Benchmarks™ content.

    Note that this part of the profile is meant to run on the Operating System that
    Red Hat OpenShift Container Platform 4 runs on top of.
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
  # 1.1.6 Ensure that the scheduler pod specification file ownership is set to root:root
  # 1.1.7 Ensure that the etcd pod specification file permissions are set to 644 or more restrictive
  # 1.1.8 Ensure that the etcd pod specification file ownership is set to root:root (Automated)
  # 1.1.9 Ensure that the Container Network Interface file permissions are set to 644 or more restrictive
  # 1.1.10 Ensure that the Container Network Interface file ownership is set to root:root
  # 1.1.11 Ensure that the etcd data directory permissions are set to 700 or more restrictive
  # 1.1.12 Ensure that the etcd data directory ownership is set to root:root
  # 1.1.13 Ensure that the admin.conf file permissions are set to 644 or more restrictive
  # 1.1.14 Ensure that the admin.conf file ownership is set to root:root 
  # 1.1.15 Ensure that the scheduler.conf file permissions are set to 644 or more restrictive
  # 1.1.16 Ensure that the scheduler.conf file ownership is set to root:root
  # 1.1.17 Ensure that the controller-manager.conf file permissions are set to 644 or more restrictive
  # 1.1.18 Ensure that the controller-manager.conf file ownership is set to root:root 
  # 1.1.19 Ensure that the OpenShift PKI directory and file ownership is set to root:root
  # 1.1.20 Ensure that the OpenShift PKI certificate file permissions are set to 644 or more restrictive
  # 1.1.21 Ensure that the OpenShift PKI key file permissions are set to 600 

  ### 3 Control Plane Configuration
  ###
  #### 3.2 Logging
  # 3.2.1 Ensure that a minimal audit policy is created

  ### 4 Worker Nodes
  ###
  #### 4.1 Worker Node Configuration Files
  # 4.1.1 Ensure that the kubelet service file permissions are set to 644 or more restrictive
  # 4.1.2 Ensure that the kubelet service file ownership is set to root:root
  # 4.1.3 If proxy kubeconfig file exists ensure permissions are set to 644 or more restrictive
  # 4.1.4 If proxy kubeconfig file exists ensure ownership is set to root:root
  # 4.1.5 Ensure that the --kubeconfig kubelet.conf file permissions are set to 644 or more restrictive
  # 4.1.6 Ensure that the --kubeconfig kubelet.conf file ownership is set to root:root
  # 4.1.7 Ensure that the certificate authorities file permissions are set to 644 or more restrictive
  # 4.1.8 Ensure that the client certificate authorities file ownership is set to root:root
  # 4.1.9 Ensure that the kubelet --config configuration file has permissions set to 644 or more restrictive
  # 4.1.10 Ensure that the kubelet configuration file ownership is set to root:root
  #### 4.2 Kubelet
  # 4.2.1 Ensure that the --anonymous-auth argument is set to false
  # 4.2.2 Ensure that the --authorization-mode argument is not set to AlwaysAllow
  # 4.2.3 Ensure that the --client-ca-file argument is set as appropriate
  # 4.2.5 Ensure that the --streaming-connection-idle-timeout argument is not set to 0 (??)
  # 4.2.6 Ensure that the --protect-kernel-defaults argument is set to true (??)
