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

extends: opencis-ocp-node

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
    - scheduler_address_argument
    - scheduler_profiling_argument
    - api-server_admission_control_plugin-AlwaysAdmit
    - api-server_admission_control_plugin-AlwaysPullImages
    - api-server_admission_control_plugin-DenyEscalatingExec
    - api-server_admission_control_plugin-EventRateLimit
    - api-server_admission_control_plugin-NamespaceLifecycle
    - api-server_admission_control_plugin-NodeRestriction
    - api-server_admission_control_plugin-PodSecurityPolicy
    - api-server_admission_control_plugin-SecurityContextDeny
    - api-server_admission_control_plugin-ServiceAccount
    - api-server_advanced-auditing
    - api-server_anonymous-auth
    - api-server_audit-log-maxage
    - api-server_audit-log-maxbackup
    - api-server_audit-log-maxsize
    - api-server_audit-log-path
    - api-server_authorization-mode
    - api-server_basic-auth-file
    - api-server_client-ca-file
    - api-server_etcd-cafile
    - api-server_etcd-certfile_and_etcd-keyfile
    - api-server_experimental-encryption-provider-cipher
    - api-server_experimental-encryption-provider-config
    - api-server_insecure-allow-any-token
    - api-server_insecure-bind-address
    - api-server_insecure-port
    - api-server_kubelet-certificate-authority
    - api-server_kubelet-client-certificate_and_kubelet-client-key
    - api-server_kubelet-https
    - api-server_profiling
    - api-server_repair-malformed-updates
    - api-server_request-timeout
    - api-server_secure-port
    - api-server_service-account-key-file
    - api-server_service-account-lookup
    - api-server_tls-cert-file_and-tle-private-key-file
    - api-server_tls-cipher-suites
    - api-server_token-auth-file
    - controller_address
    - controller_feature-gates_RotateKubeletServerCertificate_option
    - controller_profiling
    - controller_root-ca-file
    - controller_service-account-private-key-file
    - controller_terminated-pod-gc-threshhold
    - controller_use-service-account-credentials
