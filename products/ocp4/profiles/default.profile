---
documentation_complete: true

hidden: true

title: Default Profile for Red Hat OpenShift Container Platform 4

description: |-
    This profile contains all the rules that once belonged to the
    ocp4 product via 'prodtype'. This profile won't
    be rendered into an XCCDF Profile entity, nor it will select any
    of these rules by default. The only purpose of this profile
    is to keep a rule in the product's XCCDF Benchmark.

selections:
    - kubelet_enable_streaming_connections_deprecated
    - resource_requests_quota_cluster
    - scheduler_no_bind_address
    - oauthclient_token_maxage
    - kubelet_eviction_thresholds_set_hard_imagefs_inodesfree
    - api_server_api_priority_v1beta2_flowschema_catch_all
    - oauth_token_maxage
    - ingress_controller_tls_security_profile_not_old
    - file_permissions_kubeconfig
    - api_server_tls_security_profile_not_old
    - file_permissions_var_lib_etcd
    - file_owner_openvswitch
    - file_permissions_openvswitch
    - oauth_inactivity_timeout
    - kubelet_eviction_thresholds_set_soft_nodefs_inodesfree
    - file_permissions_kube_scheduler
    - kubelet_eviction_thresholds_set_soft_memory_available
    - api_server_tls_security_profile_custom_min_tls_version
    - kubelet_eviction_thresholds_set_soft_nodefs_available
    - luks_enabled_on_all_nodes
    - api_server_api_priority_v1beta1_flowschema_catch_all
    - file_permissions_pod_logs
    - kubelet_disable_hostname_override
    - azure_disk_encryption_enabled
    - kubelet_eviction_thresholds_set_soft_imagefs_inodesfree
    - file_groupowner_kubeconfig
    - api_server_api_priority_v1alpha1_flowschema_catch_all
    - api_server_api_priority_v1_flowschema_catch_all
    - file_groupowner_openvswitch
    - gcp_disk_encryption_enabled
    - ebs_encryption_enabled_on_machinesets
    - project_template_network_policy
    - file_owner_kubeconfig
    - file_owner_var_lib_etcd
    - file_groupowner_pod_logs
    - file_owner_pod_logs
    - project_config_has_template
    - kubelet_eviction_thresholds_set_soft_imagefs_available
    - ingress_controller_tls_security_profile_custom_min_tls_version
    - kubelet_read_only_port_secured
    - scheduler_port_is_zero
    - project_template_resource_quota
