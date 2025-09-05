documentation_complete: true

title: 'CIS Red Hat OpenShift Container Platform 4 Benchmark'

platform: ocp4

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

    Note that this part of the profile is meant to run on the Platform that
    Red Hat OpenShift Container Platform 4 runs on top of.

    This profile is applicable to OpenShift versions 4.6 and greater.
selections:
  ### 1 Control Plane Components
  ###
  #### 1.2 API Server
  # 1.2.1 Ensure that the --anonymous-auth argument is set to false
    - api_server_anonymous_auth
  # 1.2.2 Ensure that the --basic-auth-file argument is not set
    - api_server_basic_auth
  # 1.2.3 Ensure that the --token-auth-file parameter is not set
    - api_server_token_auth
  # 1.2.4 Ensure that the --kubelet-https argument is set to true
  # OCP doesn't use --kubelet-https but relies on TLS which is checked for in 1.2.30
  # This rule also makes sure that the services of openshift-apiserver and openshift-oauth-apiserver
  # serve TLS
    - api_server_openshift_https_serving_cert
    - api_server_oauth_https_serving_cert
  # 1.2.5 Ensure that the --kubelet-client-certificate and --kubelet-client-key arguments are set as appropriate
    - api_server_kubelet_client_cert
    - api_server_kubelet_client_key
  # 1.2.6 Ensure that the --kubelet-certificate-authority argument is set as appropriate
    - api_server_kubelet_certificate_authority
  # 1.2.7 Ensure that the --authorization-mode argument is not set to AlwaysAllow
    - api_server_auth_mode_no_aa
  # 1.2.8 Ensure that the --authorization-mode argument includes Node
    - api_server_auth_mode_node
  # 1.2.9 Ensure that the --authorization-mode argument includes RBAC
    - api_server_auth_mode_rbac
  # 1.2.10 Ensure that the admission control plugin EventRateLimit is set
    - api_server_api_priority_gate_enabled
    - api_server_api_priority_flowschema_catch_all
  # 1.2.11 Ensure that the admission control plugin AlwaysAdmit is not set
    - api_server_admission_control_plugin_AlwaysAdmit
  # 1.2.12 Ensure that the admission control plugin AlwaysPullImages is set
    # (jhrozek): This rule should temporarily be commented out as OCP diverges from CIS
    #            and we need to improve our reply to this control
    # - api_server_admission_control_plugin_AlwaysPullImages
  # 1.2.13 Ensure that the admission control plugin SecurityContextDeny is not set
    - api_server_admission_control_plugin_SecurityContextDeny
  # 1.2.14 Ensure that the admission control plugin ServiceAccount is set
    - api_server_admission_control_plugin_ServiceAccount
    - api_server_no_adm_ctrl_plugins_disabled
  # 1.2.15 Ensure that the admission control plugin NamespaceLifecycle is set
    - api_server_admission_control_plugin_NamespaceLifecycle
  # 1.2.16 Ensure that the admission control plugin PodSecurityPolicy is set (Automated)
    - api_server_admission_control_plugin_Scc
  # 1.2.17 Ensure that the admission control plugin NodeRestriction is set (Automated)
    - api_server_admission_control_plugin_NodeRestriction
  # 1.2.18 Ensure that the --insecure-bind-address argument is not set
    - api_server_insecure_bind_address
  # 1.2.19 Ensure that the --insecure-port argument is set to 0
    - api_server_insecure_port
  # 1.2.20 Ensure that the --secure-port argument is not set to 0
    - api_server_bind_address
  # 1.2.21 Ensure that the --profiling argument is set to false
    # (jhrozek): This rule should temporarily be commented out as OCP diverges from CIS
    #            and we need to improve our reply to this control
    # - api_server_profiling
  # 1.2.22 Ensure that the --audit-log-path argument is set
    - api_server_audit_log_path
    - openshift_api_server_audit_log_path
  # 1.2.23 Ensure that the audit logs are forwarded off the cluster for retention
    - audit_log_forwarding_enabled
  # 1.2.24 Ensure that the --audit-log-maxbackup argument is set to 10 or as appropriate
    - api_server_audit_log_maxbackup
    - ocp_api_server_audit_log_maxbackup
  # 1.2.25 Ensure that the --audit-log-maxsize argument is set to 100 or as appropriate
    - api_server_audit_log_maxsize
    - ocp_api_server_audit_log_maxsize
  # 1.2.26 Ensure that the --request-timeout argument is set as appropriate
    # (jhrozek) Temporarily disabling the rule because the benchmark
    #           specifies one value (60) for the request-timeout parameter, while we
    #           use 3600 in OCP. It is unclear if this value is appropriate...
    # - api_server_request_timeout
  # 1.2.27 Ensure that the --service-account-lookup argument is set to true
    - api_server_service_account_lookup
  # 1.2.28 Ensure that the --service-account-key-file argument is set as appropriate
    - api_server_service_account_public_key
  # 1.2.29 Ensure that the --etcd-certfile and --etcd-keyfile arguments are set as appropriate
    - api_server_etcd_cert
    - api_server_etcd_key
  # 1.2.30 Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate
    - api_server_tls_cert
    - api_server_tls_private_key
  # 1.2.31 Ensure that the --client-ca-file argument is set as appropriate
    - api_server_client_ca
  # 1.2.32 Ensure that the --etcd-cafile argument is set as appropriate
    - api_server_etcd_ca
  # 1.2.33 Ensure that the --encryption-provider-config argument is set as appropriate
    - api_server_encryption_provider_config
  # 1.2.34 Ensure that encryption providers are appropriately configured
    - api_server_encryption_provider_cipher
  # 1.2.35 Ensure that the API Server only makes use of Strong Cryptographic Ciphers
    - api_server_tls_cipher_suites
  #### 1.3 Controller Manager
  # 1.3.1 Ensure that garbage collection is configured as appropriate (Manual)
  # 1.3.2 Ensure that controller manager healthz endpoints are protected by RBAC. (Automated)
    - rbac_debug_role_protects_pprof
  # 1.3.3 Ensure that the --use-service-account-credentials argument is set to true
    - controller_use_service_account
  # 1.3.4 Ensure that the --service-account-private-key-file argument is set as appropriate
    - controller_service_account_private_key
  # 1.3.5 Ensure that the --root-ca-file argument is set as appropriate
    - controller_service_account_ca
  # 1.3.6 Ensure that the RotateKubeletServerCertificate argument is set to true
    - controller_rotate_kubelet_server_certs
  # 1.3.7 Ensure that the --bind-address argument is set to 127.0.0.1
    - controller_secure_port
    - controller_insecure_port_disabled
  #### 1.4 Scheduler
  # 1.4.1 Ensure that the --profiling argument is set to false  (info only)
  # Handled by rbac_debug_role_protects_pprof
  # 1.4.2 Ensure that the --bind-address argument is set to 127.0.0.1
    - scheduler_no_bind_address

  ### 2 etcd
  # 2.1 Ensure that the --cert-file and --key-file arguments are set as appropriate
    - etcd_cert_file
    - etcd_key_file
  # 2.2 Ensure that the --client-cert-auth argument is set to true
    - etcd_client_cert_auth
  # 2.3 Ensure that the --auto-tls argument is not set to true
    - etcd_auto_tls
  # 2.4 Ensure that the --peer-cert-file and --peer-key-file arguments are set as appropriate
    - etcd_peer_cert_file
    - etcd_peer_key_file
  # 2.5 Ensure that the --peer-client-cert-auth argument is set to true
    - etcd_peer_client_cert_auth
  # 2.6 Ensure that the --peer-auto-tls argument is not set to true
    - etcd_peer_auto_tls

  ### 3 Control Plane Configuration
  ###
  #### 3.1 Authentication and Authorization
  # 3.1.1 Client certificate authentication should not be used for users
  #### 3.2 Logging
  # 3.2.1 Ensure that a minimal audit policy is created
  # 3.2.2 Ensure that the audit policy covers key security concerns

  ### 4 Worker Nodes
  ###
  #### 4.2 Kubelet
  # 4.2.4 Ensure that the --read-only-port argument is set to 0
    - kubelet_disable_readonly_port
  # 4.2.10 Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate
    - kubelet_configure_tls_cert
    # Like kubelet_disable_readonly_port but check for .apiServerArguments["kubelet-client-certificate"]
    - kubelet_configure_tls_key
    # Like kubelet_disable_readonly_port but check for .apiServerArguments["kubelet-client-key"]
  # 4.2.13 Ensure that the Kubelet only makes use of Strong Cryptographic Ciphers

  ### 5 Policies
  ###
  #### 5.1 RBAC and Service Accounts
  # 5.1.1 Ensure that the cluster-admin role is only used where required
    - rbac_limit_cluster_admin
  # 5.1.2 Minimize access to secrets (info)
    - rbac_limit_secrets_access
  # 5.1.3 Minimize wildcard use in Roles and ClusterRoles (info)
    - rbac_wildcard_use
  # 5.1.4 Minimize access to create pods (info)
    - rbac_pod_creation_access
  # 5.1.5 Ensure that default service accounts are not actively used. (info)
    - accounts_unique_service_account
  # 5.1.6 Ensure that Service Account Tokens are only mounted where necessary (info)
    - accounts_restrict_service_account_tokens
  #### 5.2 Pod Security Policies / Security Context Constraints
  # 5.2.1 Minimize the admission of privileged containers (info)
    - scc_limit_privileged_containers
  # 5.2.2 Minimize the admission of containers wishing to share the host process ID namespace (info)
    - scc_limit_process_id_namespace
  # 5.2.3 Minimize the admission of containers wishing to share the host IPC namespace (info)
    - scc_limit_ipc_namespace
  # 5.2.4 Minimize the admission of containers wishing to share the host network namespace (info)
    - scc_limit_network_namespace
  # 5.2.5 Minimize the admission of containers with allowPrivilegeEscalation (info)
    - scc_limit_privilege_escalation
  # 5.2.6 Minimize the admission of root containers (info)
    - scc_limit_root_containers
  # 5.2.7 Minimize the admission of containers with the NET_RAW capability (info)
    - scc_limit_net_raw_capability
  # 5.2.8 Minimize the admission of containers with added capabilities (info)
    - scc_limit_container_allowed_capabilities
  # 5.2.9 Minimize the admission of containers with capabilities assigned (info)
    - scc_drop_container_capabilities
  #### 5.3 Network Policies and CNI
  # 5.3.1 Ensure that the CNI in use supports Network Policies (info)
    - configure_network_policies
  # 5.3.2 Ensure that all Namespaces have Network Policies defined (info)
    - configure_network_policies_namespaces
  #### 5.4 Secrets Management
  # 5.4.1 Prefer using secrets as files over secrets as environment variables (info)
    - secrets_no_environment_variables
  # 5.4.2 Consider external secret storage (info)
  #### 5.5 Extensible Admission Control
  # 5.5.1 Configure Image Provenance using ImagePolicyWebhook admission controller
    - general_configure_imagepolicywebhook
