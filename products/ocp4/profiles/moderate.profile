documentation_complete: true

metadata:
    SMEs:
        - JAORMX
        - mrogers950
        - carlosmmatos

reference: https://nvd.nist.gov/800-53/Rev4/impact/moderate

title: 'NIST 800-53 Moderate-Impact Baseline for Red Hat OpenShift - Platform level'

platform: ocp4

description: |-
    This compliance profile reflects the core set of Moderate-Impact Baseline
    configuration settings for deployment of Red Hat OpenShift Container
    Platform into U.S. Defense, Intelligence, and Civilian agencies.
    Development partners and sponsors include the U.S. National Institute
    of Standards and Technology (NIST), U.S. Department of Defense,
    the National Security Agency, and Red Hat.

    This baseline implements configuration requirements from the following
    sources:

    - NIST 800-53 control selections for Moderate-Impact systems (NIST 800-53)

    For any differing configuration requirements, e.g. password lengths, the stricter
    security setting was chosen. Security Requirement Traceability Guides (RTMs) and
    sample System Security Configuration Guides are provided via the
    scap-security-guide-docs package.

    This profile reflects U.S. Government consensus content and is developed through
    the ComplianceAsCode initiative, championed by the National
    Security Agency. Except for differences in formatting to accommodate
    publishing processes, this profile mirrors ComplianceAsCode
    content as minor divergences, such as bugfixes, work through the
    consensus and release processes.

selections:
    # AC-2(5)
    - var_oauth_inactivity_timeout=10m0s
    - oauth_or_oauthclient_inactivity_timeout
    # AC-2, AC-7
    - ocp_idp_no_htpasswd
    - kubeadmin_removed
    # AC-12
    - oauth_or_oauthclient_token_maxage

    - ocp_allowed_registries_for_import
    - ocp_allowed_registries

    # AC-8: SYSTEM USE NOTIFICATION
    - openshift_motd_exists
    - banner_or_login_template_set

    # AU
    - var_openshift_audit_profile=WriteRequestBodies
    - audit_profile_set

    # AU-5 RESPONSE TO AUDIT PROCESSING FAILURES
    - audit_error_alert_exists

    # AU-9
    - audit_log_forwarding_enabled
    - audit_log_forwarding_uses_tls

    # CM-6 CONFIGURATION SETTINGS
    # CM-6(1) CONFIGURATION SETTINGS | AUTOMATED CENTRAL MANAGEMENT / APPLICATION / VERIFICATION
    - api_server_anonymous_auth
    - api_server_basic_auth
    - api_server_token_auth
    - api_server_kubelet_client_cert
    - api_server_kubelet_client_key
    - api_server_kubelet_certificate_authority
    - api_server_auth_mode_no_aa
    - api_server_auth_mode_node
    - api_server_auth_mode_rbac
    - api_server_api_priority_gate_enabled
    - api_server_api_priority_flowschema_catch_all
    - api_server_api_priority_v1alpha1_flowschema_catch_all
    - api_server_admission_control_plugin_AlwaysAdmit
    - api_server_admission_control_plugin_AlwaysPullImages
    - api_server_admission_control_plugin_SecurityContextDeny
    - api_server_admission_control_plugin_ServiceAccount
    - api_server_no_adm_ctrl_plugins_disabled
    - api_server_admission_control_plugin_NamespaceLifecycle
    - api_server_admission_control_plugin_Scc
    - api_server_admission_control_plugin_NodeRestriction
    - api_server_insecure_bind_address
    - api_server_insecure_port
    - api_server_bind_address
    - api_server_profiling_protected_by_rbac
    - api_server_audit_log_path
    - openshift_api_server_audit_log_path
    - api_server_audit_log_maxbackup
    - ocp_api_server_audit_log_maxbackup
    - api_server_audit_log_maxsize
    - ocp_api_server_audit_log_maxsize
    - api_server_request_timeout
    - api_server_service_account_lookup
    - api_server_service_account_public_key
    - rbac_debug_role_protects_pprof
    - controller_use_service_account
    - file_permissions_proxy_kubeconfig
    - file_owner_proxy_kubeconfig
    - file_groupowner_proxy_kubeconfig
    - kubelet_disable_readonly_port
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
    - secrets_no_environment_variables
    - secrets_consider_external_storage
    - general_configure_imagepolicywebhook
    - general_namespaces_in_use
    - general_default_seccomp_profile
    - general_apply_scc
    - general_default_namespace_use

    # RA-5 VULNERABILITY SCANNING
    - compliancesuite_exists

    # SC-28 PROTECTION OF INFORMATION AT REST
    # SC-28 (1) PROTECTION OF INFORMATION AT REST | CRYPTOGRAPHIC PROTECTION
    - api_server_encryption_provider_config
    - api_server_encryption_provider_cipher

    # SC-7(8)
    - cluster_wide_proxy_set

    # SC-8: TRANSMISSION CONFIDENTIALITY AND INTEGRITY
    - ocp_no_ldap_insecure
    # SC-8(1): TRANSMISSION CONFIDENTIALITY AND INTEGRITY | CRYPTOGRAPHIC OR ALTERNATE PHYSICAL PROTECTION
    - api_server_client_ca
    - api_server_etcd_ca
    - api_server_etcd_cert
    - api_server_etcd_key
    - api_server_https_for_kubelet_conn
    - api_server_oauth_https_serving_cert
    - api_server_openshift_https_serving_cert
    - api_server_tls_cert
    - api_server_tls_private_key
    - controller_insecure_port_disabled
    - controller_rotate_kubelet_server_certs
    - controller_secure_port
    - controller_service_account_ca
    - controller_service_account_private_key
    - etcd_auto_tls
    - etcd_cert_file
    - etcd_client_cert_auth
    - etcd_key_file
    - etcd_peer_auto_tls
    - etcd_peer_cert_file
    - etcd_peer_client_cert_auth
    - etcd_peer_key_file
    - kubelet_configure_tls_cert
    - kubelet_configure_tls_key
    - routes_protected_by_tls
    - scheduler_no_bind_address

    # SC-13: CRYPTOGRAPHIC PROTECTION
    - fips_mode_enabled

    # SI-7: SOFTWARE, FIRMWARE, AND INFORMATION INTEGRITY
    - file_integrity_exists
