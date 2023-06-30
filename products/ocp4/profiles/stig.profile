documentation_complete: false

platform: ocp4

metadata:
    SMEs:
        - jhrozek
        - Vincent056
        - mrogers950
        - rhmdnd
        - david-rh

reference: https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_Container_Platform_V1R3_SRG.zip

title: '[DRAFT] DISA STIG for Red Hat OpenShift Container Platform 4 - Platform level'

description: |-
    This is a draft profile for experimental purposes. It is not based on the 
    DISA STIG for OCP4, because one was not available at the time yet. This 
    profile contains configuration checks that align to the DISA STIG for 
    Red Hat OpenShift Container Platform 4.

filter_rules: '"ocp4-node" not in platforms and "ocp4-master-node" not in platforms and "ocp4-node-on-sdn" not in platforms and "ocp4-node-on-ovn" not in platforms'

selections:
    - srg_ctr:all
  ### Variables
    - var_openshift_audit_profile=WriteRequestBodies
  ### Helper Rules
  ### This is a helper rule to fetch the required api resource for detecting OCP version
    - version_detect_in_ocp
    - version_detect_in_hypershift
  ### CIS rules.
  ### Generated with yq '... comments=""' < products/ocp4/profiles/cis.profile | yq '.selections' >> products/ocp4/profiles/stig.profile
    - api_server_anonymous_auth
    - api_server_basic_auth
    - api_server_token_auth
    - api_server_https_for_kubelet_conn
    - api_server_openshift_https_serving_cert
    - api_server_oauth_https_serving_cert
    - api_server_kubelet_client_cert
    - api_server_kubelet_client_cert_pre_4_9
    - api_server_kubelet_client_key
    - api_server_kubelet_client_key_pre_4_9
    - api_server_kubelet_certificate_authority
    - api_server_auth_mode_no_aa
    - api_server_auth_mode_node
    - api_server_auth_mode_rbac
    - api_server_api_priority_gate_enabled
    - api_server_api_priority_flowschema_catch_all
    - api_server_admission_control_plugin_alwaysadmit
    - api_server_admission_control_plugin_alwayspullimages
    - api_server_admission_control_plugin_securitycontextdeny
    - api_server_admission_control_plugin_service_account
    - api_server_no_adm_ctrl_plugins_disabled
    - api_server_admission_control_plugin_namespacelifecycle
    - api_server_admission_control_plugin_scc
    - api_server_admission_control_plugin_noderestriction
    - api_server_insecure_bind_address
    - api_server_insecure_port
    - api_server_bind_address
    - api_server_profiling_protected_by_rbac
    - api_server_audit_log_path
    - openshift_api_server_audit_log_path
    - audit_log_forwarding_enabled
    - audit_log_forwarding_webhook
    - api_server_audit_log_maxbackup
    - ocp_api_server_audit_log_maxbackup
    - api_server_audit_log_maxsize
    - ocp_api_server_audit_log_maxsize
    - api_server_request_timeout
    - api_server_service_account_lookup
    - api_server_service_account_public_key
    - api_server_etcd_cert
    - api_server_etcd_key
    - api_server_tls_cert
    - api_server_tls_private_key
    - api_server_client_ca
    - api_server_etcd_ca
    - api_server_encryption_provider_cipher
    - api_server_tls_cipher_suites
    - kubelet_eviction_thresholds_set_hard_memory_available
    - kubelet_eviction_thresholds_set_hard_nodefs_available
    - kubelet_eviction_thresholds_set_hard_nodefs_inodesfree
    - kubelet_eviction_thresholds_set_hard_imagefs_available
    - rbac_debug_role_protects_pprof
    - controller_use_service_account
    - controller_service_account_private_key
    - controller_service_account_ca
    - controller_rotate_kubelet_server_certs
    - controller_secure_port
    - controller_insecure_port_disabled
    - etcd_cert_file
    - etcd_key_file
    - etcd_client_cert_auth
    - etcd_auto_tls
    - etcd_peer_cert_file
    - etcd_peer_key_file
    - etcd_peer_client_cert_auth
    - etcd_peer_auto_tls
    - idp_is_configured
    - kubeadmin_removed
    - audit_profile_set
    - file_permissions_proxy_kubeconfig
    - file_owner_proxy_kubeconfig
    - file_groupowner_proxy_kubeconfig
    - kubelet_anonymous_auth
    - kubelet_authorization_mode
    - kubelet_configure_client_ca
    - kubelet_disable_readonly_port
    - kubelet_enable_streaming_connections
    - kubelet_enable_iptables_util_chains
    - kubelet_configure_event_creation
    - kubelet_configure_tls_cert
    - kubelet_configure_tls_cert_pre_4_9
    - kubelet_configure_tls_key
    - kubelet_configure_tls_key_pre_4_9
    - kubelet_enable_client_cert_rotation
    - kubelet_enable_cert_rotation
    - kubelet_enable_server_cert_rotation
    - kubelet_configure_tls_cipher_suites
    - rbac_limit_cluster_admin
    - rbac_limit_secrets_access
    - rbac_wildcard_use
    - rbac_pod_creation_access
    - accounts_unique_service_account
    - accounts_restrict_service_account_tokens
    - scc_limit_privileged_containers
    - scc_limit_process_id_namespace
    - scc_limit_ipc_namespace
    - scc_limit_network_namespace
    - scc_limit_privilege_escalation
    - scc_limit_root_containers
    - scc_limit_net_raw_capability
    - scc_limit_container_allowed_capabilities
    - scc_drop_container_capabilities
    - configure_network_policies
    - configure_network_policies_namespaces
    - configure_network_policies_hypershift_hosted
    - secrets_no_environment_variables
    - secrets_consider_external_storage
    - general_configure_imagepolicywebhook
    - general_namespaces_in_use
    - general_default_seccomp_profile
    - general_apply_scc
    - general_default_namespace_use
