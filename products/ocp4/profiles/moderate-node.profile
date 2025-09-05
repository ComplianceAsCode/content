documentation_complete: true

title: 'NIST 800-53 Moderate-Impact Baseline for Red Hat OpenShift - Node level'

platform: ocp4-node

metadata:
    SMEs:
        - JAORMX
        - mrogers950
        - jhrozek

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

    # AU-9
    - directory_access_var_log_kube_audit
    - directory_permissions_var_log_kube_audit
    - file_ownership_var_log_kube_audit
    - file_permissions_var_log_kube_audit
    - directory_access_var_log_ocp_audit
    - directory_permissions_var_log_ocp_audit
    - file_ownership_var_log_ocp_audit
    - file_permissions_var_log_ocp_audit
    - directory_access_var_log_oauth_audit
    - directory_permissions_var_log_oauth_audit
    - file_ownership_var_log_oauth_audit
    - file_permissions_var_log_oauth_audit

    # CM-6 CONFIGURATION SETTINGS
    # CM-6(1) CONFIGURATION SETTINGS | AUTOMATED CENTRAL MANAGEMENT / APPLICATION / VERIFICATION
    - etcd_unique_ca
    - file_groupowner_cni_conf
    - file_groupowner_controller_manager_kubeconfig
    - file_groupowner_etcd_data_dir
    - file_groupowner_etcd_data_files
    - file_groupowner_etcd_member
    - file_groupowner_etcd_pki_cert_files
    - file_groupowner_ip_allocations
    - file_groupowner_kube_apiserver
    - file_groupowner_kube_controller_manager
    - file_groupowner_kube_scheduler
    - file_groupowner_kubelet_conf
    - file_groupowner_master_admin_kubeconfigs
    - file_groupowner_multus_conf
    - file_groupowner_openshift_pki_cert_files
    - file_groupowner_openshift_pki_key_files
    - file_groupowner_openshift_sdn_cniserver_config
    - file_groupowner_ovs_conf_db
    - file_groupowner_ovs_conf_db_lock
    - file_groupowner_ovs_pid
    - file_groupowner_ovs_sys_id_conf
    - file_groupowner_ovs_vswitchd_pid
    - file_groupowner_ovsdb_server_pid
    - file_groupowner_scheduler_kubeconfig
    - file_groupowner_worker_ca
    - file_groupowner_worker_kubeconfig
    - file_groupowner_worker_service
    - file_owner_cni_conf
    - file_owner_controller_manager_kubeconfig
    - file_owner_etcd_data_dir
    - file_owner_etcd_data_files
    - file_owner_etcd_member
    - file_owner_etcd_pki_cert_files
    - file_owner_ip_allocations
    - file_owner_kube_apiserver
    - file_owner_kube_controller_manager
    - file_owner_kube_scheduler
    - file_owner_kubelet_conf
    - file_owner_master_admin_kubeconfigs
    - file_owner_multus_conf
    - file_owner_openshift_pki_cert_files
    - file_owner_openshift_pki_key_files
    - file_owner_openshift_sdn_cniserver_config
    - file_owner_ovs_conf_db
    - file_owner_ovs_conf_db_lock
    - file_owner_ovs_pid
    - file_owner_ovs_sys_id_conf
    - file_owner_ovs_vswitchd_pid
    - file_owner_ovsdb_server_pid
    - file_owner_scheduler_kubeconfig
    - file_owner_worker_ca
    - file_owner_worker_kubeconfig
    - file_owner_worker_service
    - file_permissions_cni_conf
    - file_permissions_controller_manager_kubeconfig
    - file_permissions_etcd_data_dir
    - file_permissions_etcd_data_files
    - file_permissions_etcd_member
    - file_permissions_etcd_pki_cert_files
    - file_permissions_ip_allocations
    - file_permissions_kube_apiserver
    - file_permissions_kube_controller_manager
    - file_permissions_kubelet_conf
    - file_permissions_master_admin_kubeconfigs
    - file_permissions_multus_conf
    - file_permissions_openshift_pki_cert_files
    - file_permissions_openshift_pki_key_files
    - file_permissions_ovs_conf_db
    - file_permissions_ovs_conf_db_lock
    - file_permissions_ovs_pid
    - file_permissions_ovs_sys_id_conf
    - file_permissions_ovs_vswitchd_pid
    - file_permissions_ovsdb_server_pid
    - file_permissions_scheduler
    - file_permissions_scheduler_kubeconfig
    - file_permissions_worker_ca
    - file_permissions_worker_kubeconfig
    - file_permissions_worker_service
    - file_perms_openshift_sdn_cniserver_config
    - kubelet_anonymous_auth
    - kubelet_authorization_mode
    - kubelet_configure_client_ca
    - kubelet_configure_event_creation
    - kubelet_configure_tls_cipher_suites
    - kubelet_disable_hostname_override
    - kubelet_enable_cert_rotation
    - kubelet_enable_client_cert_rotation
    - kubelet_enable_iptables_util_chains
    - kubelet_enable_protect_kernel_defaults
    - kubelet_enable_server_cert_rotation
    - kubelet_enable_streaming_connections
    - kubelet_eviction_thresholds_set_hard_imagefs_available
    - kubelet_eviction_thresholds_set_hard_imagefs_inodesfree
    - kubelet_eviction_thresholds_set_hard_memory_available
    - kubelet_eviction_thresholds_set_hard_nodefs_available
    - kubelet_eviction_thresholds_set_hard_nodefs_inodesfree
    - kubelet_eviction_thresholds_set_soft_imagefs_available
    - kubelet_eviction_thresholds_set_soft_imagefs_inodesfree
    - kubelet_eviction_thresholds_set_soft_memory_available
    - kubelet_eviction_thresholds_set_soft_nodefs_available
    - kubelet_eviction_thresholds_set_soft_nodefs_inodesfree