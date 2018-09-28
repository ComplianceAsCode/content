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
    - address_argument
    - profiling_argument
    - admission_control_plugin-AlwaysAdmit
    - admission_control_plugin-AlwaysPullImages
    - admission_control_plugin-DenyEscalatingExec
    - admission_control_plugin-EventRateLimit
    - admission_control_plugin-NamespaceLifecycle
    - admission_control_plugin-NodeRestriction
    - admission_control_plugin-PodSecurityPolicy
    - admission_control_plugin-SecurityContextDeny
    - admission_control_plugin-ServiceAccount
    - advanced-auditing_enabled
    - anonymous-auth_argument
    - audit-log-maxage_argument
    - audit-log-maxbackup_argument
    - audit-log-maxsize_argument
    - audit-log-path_argument
    - authorization-mode_argument
    - basic-auth-file_argument
    - client-ca-file_argument
    - etcd-cafile_argument
    - etcd-certfile_and_etcd-keyfile_arguments
    - experimental-encryption-provider-cipher
    - experimental-encryption-provider-config_argument
    - insecure-allow-any-token_argument
    - insecure-bind-address_argument
    - insecure-port_argument
    - kubelet-certificate-authority_argument
    - kubelet-client-certificate_and_kubelet-client-key_arguments
    - kubelet-https_argument
    - profiling_argument
    - repair-malformed-updates_argument
    - request-timeout_argument
    - secure-port_argument
    - service-account-key-file_argument
    - service-account-lookup_argument
    - tls-cert-file_and-tle-private-key-file_arguments
    - tls-cipher-suites_argument
    - token-auth-file_argument
