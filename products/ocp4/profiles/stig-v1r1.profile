documentation_complete: true

platform: ocp4

metadata:
    version: V1R1
    SMEs:
        - jhrozek
        - Vincent056
        - mrogers950
        - rhmdnd
        - david-rh

reference: https://public.cyber.mil/stigs/downloads/

title: 'DISA STIG for Red Hat OpenShift Container Platform 4 - Platform level'

description: |-
    This profile contains configuration checks that align to the DISA STIG for
    Red Hat OpenShift Container Platform 4.

filter_rules: '"ocp4-node" not in platforms and "ocp4-master-node" not in platforms and "ocp4-node-on-sdn" not in platforms and "ocp4-node-on-ovn" not in platforms'

selections:
    - stig_ocp4:all
  ### Variables
    - var_openshift_audit_profile=WriteRequestBodies
    - var_oauth_token_maxage=8h
  ### Helper Rules
  ### This is a helper rule to fetch the required api resource for detecting OCP version
    - version_detect_in_ocp
    - version_detect_in_hypershift
    # Manually add rules from SRG-APP-000516-CTR-001325, the SRG is not referenced in the published STIG.
    - accounts_restrict_service_account_tokens
    - accounts_unique_service_account
    - api_server_admission_control_plugin_alwaysadmit
    - api_server_admission_control_plugin_alwayspullimages
    - api_server_admission_control_plugin_namespacelifecycle
    - api_server_admission_control_plugin_noderestriction
    - api_server_admission_control_plugin_scc
    - api_server_admission_control_plugin_securitycontextdeny
    - api_server_admission_control_plugin_service_account
    - api_server_anonymous_auth
    - api_server_api_priority_flowschema_catch_all
    - api_server_api_priority_gate_enabled
    - api_server_audit_log_maxbackup
    - api_server_audit_log_maxsize
    - api_server_audit_log_path
    - api_server_auth_mode_no_aa
    - api_server_auth_mode_node
    - api_server_auth_mode_rbac
    - api_server_basic_auth
    - api_server_bind_address
    - api_server_etcd_cert
    - api_server_etcd_key
    - api_server_https_for_kubelet_conn
    - api_server_insecure_bind_address
    - api_server_insecure_port
    - api_server_kubelet_certificate_authority
    - api_server_kubelet_client_cert
    - api_server_kubelet_client_cert_pre_4_9
    - api_server_kubelet_client_key
    - api_server_kubelet_client_key_pre_4_9
    - api_server_no_adm_ctrl_plugins_disabled
    - api_server_oauth_https_serving_cert
    - api_server_openshift_https_serving_cert
    - api_server_profiling_protected_by_rbac
    - api_server_request_timeout
    - api_server_service_account_lookup
    - api_server_service_account_public_key
    - api_server_tls_cipher_suites
    - api_server_token_auth
    - controller_insecure_port_disabled
    - controller_secure_port
    - controller_service_account_ca
    - controller_service_account_private_key
    - controller_use_service_account
    - etcd_auto_tls
    - etcd_cert_file
    - etcd_client_cert_auth
    - etcd_key_file
    - etcd_peer_auto_tls
    - etcd_peer_client_cert_auth
    - file_groupowner_proxy_kubeconfig
    - file_integrity_exists
    - file_owner_proxy_kubeconfig
    - file_permissions_proxy_kubeconfig
    - general_apply_scc
    - general_configure_imagepolicywebhook
    - general_default_namespace_use
    - general_default_seccomp_profile
    - general_namespaces_in_use
    - kubelet_disable_readonly_port
    - ocp_api_server_audit_log_maxbackup
    - ocp_api_server_audit_log_maxsize
    - openshift_api_server_audit_log_path
    - rbac_debug_role_protects_pprof
    - rbac_limit_cluster_admin
    - rbac_limit_secrets_access
    - rbac_pod_creation_access
    - rbac_wildcard_use
    - scc_drop_container_capabilities
    - scc_limit_container_allowed_capabilities
    - scc_limit_net_raw_capability
    - scc_limit_privilege_escalation
    - secrets_consider_external_storage
    - secrets_no_environment_variables
