documentation_complete: false

platform: ocp4-node

metadata:
    SMEs:
        - jhrozek
        - Vincent056
        - mrogers950
        - rhmdnd
        - david-rh

reference: https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_Container_Platform_V1R3_SRG.zip

title: '[DRAFT] DISA STIG for Red Hat OpenShift Container Platform 4 - Node level'

description: |-
    This is a draft profile for experimental purposes. It is not based on the 
    DISA STIG for OCP4, because one was not available at the time yet. This 
    profile contains configuration checks that align to the DISA STIG for 
    Red Hat OpenShift Container Platform 4.

filter_rules: '"ocp4-node" in platforms or "ocp4-master-node" in platforms or "ocp4-node-on-sdn" in platforms or "ocp4-node-on-ovn" in platforms'

selections:
    - srg_ctr:all

    # CIS rules. Generated with yq '... comments=""' < products/ocp4/profiles/cis-node.profile | yq '.selections' >> products/ocp4/profiles/stig-node.profile
    - file_permissions_kube_apiserver
    - file_owner_kube_apiserver
    - file_groupowner_kube_apiserver
    - file_permissions_kube_controller_manager
    - file_owner_kube_controller_manager
    - file_groupowner_kube_controller_manager
    - file_permissions_scheduler
    - file_owner_kube_scheduler
    - file_groupowner_kube_scheduler
    - file_permissions_etcd_member
    - file_owner_etcd_member
    - file_groupowner_etcd_member
    - file_permissions_cni_conf
    - file_permissions_multus_conf
    - file_permissions_ip_allocations
    - file_perms_openshift_sdn_cniserver_config
    - file_permissions_ovs_pid
    - file_permissions_ovs_conf_db
    - file_permissions_ovs_sys_id_conf
    - file_permissions_ovs_conf_db_lock
    - file_permissions_ovs_vswitchd_pid
    - file_permissions_ovsdb_server_pid
    - file_permissions_ovn_cni_server_sock
    - file_permissions_ovn_db_files
    - file_owner_cni_conf
    - file_groupowner_cni_conf
    - file_owner_multus_conf
    - file_groupowner_multus_conf
    - file_owner_ip_allocations
    - file_groupowner_ip_allocations
    - file_owner_openshift_sdn_cniserver_config
    - file_groupowner_openshift_sdn_cniserver_config
    - file_owner_ovs_pid
    - file_groupowner_ovs_pid
    - file_owner_ovs_conf_db
    - file_groupowner_ovs_conf_db
    - file_owner_ovs_sys_id_conf
    - file_groupowner_ovs_sys_id_conf
    - file_owner_ovs_conf_db_lock
    - file_groupowner_ovs_conf_db_lock
    - file_owner_ovs_vswitchd_pid
    - file_groupowner_ovs_vswitchd_pid
    - file_owner_ovsdb_server_pid
    - file_groupowner_ovsdb_server_pid
    - file_groupowner_ovn_cni_server_sock
    - file_owner_ovn_cni_server_sock
    - file_owner_ovn_db_files
    - file_groupowner_ovn_db_files
    - file_permissions_etcd_data_dir
    - file_permissions_etcd_data_files
    - file_owner_etcd_data_dir
    - file_groupowner_etcd_data_dir
    - file_owner_etcd_data_files
    - file_groupowner_etcd_data_files
    - file_permissions_master_admin_kubeconfigs
    - file_owner_master_admin_kubeconfigs
    - file_groupowner_master_admin_kubeconfigs
    - file_permissions_scheduler_kubeconfig
    - file_owner_scheduler_kubeconfig
    - file_groupowner_scheduler_kubeconfig
    - file_permissions_controller_manager_kubeconfig
    - file_owner_controller_manager_kubeconfig
    - file_groupowner_controller_manager_kubeconfig
    - file_owner_openshift_pki_key_files
    - file_groupowner_openshift_pki_key_files
    - file_owner_openshift_pki_cert_files
    - file_groupowner_openshift_pki_cert_files
    - file_owner_etcd_pki_cert_files
    - file_groupowner_etcd_pki_cert_files
    - file_permissions_openshift_pki_cert_files
    - file_permissions_etcd_pki_cert_files
    - file_permissions_openshift_pki_key_files
    - etcd_unique_ca
    - file_permissions_worker_service
    - file_owner_worker_service
    - file_groupowner_worker_service
    - file_permissions_kubelet_conf
    - file_groupowner_kubelet_conf
    - file_groupowner_kubelet
    - file_owner_kubelet_conf
    - file_owner_kubelet
    - file_permissions_worker_ca
    - file_owner_worker_ca
    - file_groupowner_worker_ca
    - file_permissions_worker_kubeconfig
    - file_owner_worker_kubeconfig
    - file_groupowner_worker_kubeconfig
    - kubelet_enable_protect_kernel_sysctl
    - kubelet_enable_protect_kernel_defaults
