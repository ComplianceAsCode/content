documentation_complete: true

title: 'Open Computing Information Security Profile for OpenShift Master Node'

description: |-
    This baseline was inspired by the Center for Internet Security
    (CIS) Kubernetes Benchmark, v1.2.0 - 01-31-2017.

    For the ComplianceAsCode project to remain in compliance with
    CIS' terms and conditions, specifically Restrictions(8), note
    there is no representation or claim that the OpenCIS profile will
    ensure a system is in compliance or consistency with the CIS
    baseline.

extends: opencis-node

selections:
    - file_groupowner_etc_origin
    - file_groupowner_master_admin_conf
    - file_groupowner_master_api_server
    - file_groupowner_master_cni_conf
    - file_groupowner_master_controller_manager
    - file_groupowner_master_etcd
    - file_groupowner_master_openshift_conf
    - file_groupowner_master_openshift_kubeconfig
    - file_groupowner_master_scheduler_conf
    - file_groupowner_var_lib_etcd
    - file_owner_etc_origin
    - file_owner_master_admin_conf
    - file_owner_master_api_server
    - file_owner_master_cni_conf
    - file_owner_master_controller_manager
    - file_owner_master_etcd
    - file_owner_master_openshift_conf
    - file_owner_master_openshift_kubeconfig
    - file_owner_master_scheduler_conf
    - file_owner_var_lib_etcd
    - file_permissions_etc_origin
    - file_permissions_master_admin_conf
    - file_permissions_master_api_server
    - file_permissions_master_cni_conf
    - file_permissions_master_controller_manager
    - file_permissions_master_etcd
    - file_permissions_master_openshift_conf
    - file_permissions_master_openshift_kubeconfig
    - file_permissions_master_scheduler_conf
    - file_permissions_var_lib_etcd
    - file_groupowner_master_openvswitch
    - file_owner_master_openvswitch
    - file_permissions_master_openvswitch
    - scheduler_profiling_argument
    - controller_bind_address
    - controller_disable_profiling
    - controller_rotate_kubelet_server_certs
    - controller_terminated_pod_gc_threshhold
    - controller_use_service_account
    - etcd_auto_tls
    - etcd_cert_file
    - etcd_client_cert_auth
    - etcd_key_file
    - etcd_max_wals
    - etcd_peer_auto_tls
    - etcd_peer_cert_file
    - etcd_peer_client_cert_auth
    - etcd_peer_key_file
    - etcd_unique_ca
    - etcd_wal_dir
    - api_server_admission_control_plugin_AlwaysAdmit
    - api_server_admission_control_plugin_AlwaysPullImages
    - api_server_admission_control_plugin_DenyEscalatingExec
    - api_server_admission_control_plugin_EventRateLimit
    - api_server_admission_control_plugin_NamespaceLifecycle
    - api_server_admission_control_plugin_NodeRestriction
    - api_server_admission_control_plugin_PodSecurityPolicy
    - api_server_admission_control_plugin_SecurityContextDeny
    - api_server_admission_control_plugin_ServiceAccount
    - api_server_advanced_auditing
    - api_server_anonymous_auth
    - api_server_audit_log_maxage
    - api_server_audit_log_maxbackup
    - api_server_audit_log_maxsize
    - api_server_audit_log_path
    - api_server_authorization_mode
    - api_server_basic_auth
    - api_server_client_ca
    - api_server_etcd_ca
    - api_server_etcd_cert
    - api_server_etcd_key
    - api_server_experimental_encryption_provider_cipher
    - api_server_experimental_encryption_provider_config
    - api_server_insecure_allow_any_token
    - api_server_insecure_bind_address
    - api_server_insecure_port
    - api_server_kubelet_certificate_authority
    - api_server_kubelet_client_cert
    - api_server_kubelet_client_key
    - api_server_kubelet_https
    - api_server_request_timeout
    - api_server_secure_port
    - api_server_service_account_ca
    - api_server_service_account_private_key
    - api_server_service_account_public_key
    - api_server_tls_cert
    - api_server_tls_cipher_suites
    - api_server_tls_private_key
    - api_server_token_auth
