documentation_complete: true

title: 'Open Computing Information Security Profile for OpenShift Node'

description: |-
    This baseline was inspired by the Center for Internet Security
    (CIS) Kubernetes Benchmark, v1.2.0 - 01-31-2017.

    For the ComplianceAsCode project to remain in compliance with
    CIS' terms and conditions, specifically Restrictions(8), note
    there is no representation or claim that the OpenCIS profile will
    ensure a system is in compliance or consistency with the CIS
    baseline.

selections:
    - file_permissions_node_config
    #- file_owner_node_config
    #- file_groupowner_node_config
    #- file_permissions_openshift_node_client_crt
    #- file_owner_openshift_node_client_crt
    #- file_groupowner_openshift_node_client_crt
    #- file_permissions_openshift_node_service
    #- file_owner_openshift_node_service
    #- file_groupowner_openshift_node_service
    #- kubelet_configure_client_ca
    #- kubelet_configure_event_creation
    #- kubelet_configure_tls_cert
    #- kubelet_configure_tls_key
    #- kubelet_disable_cadvisor_port
    #- kubelet_disable_hostname_override
    #- kubelet_disable_readonly_port
    #- kubelet_enable_client_cert_rotation
    #- kubelet_enable_server_cert_rotation
    #- kubelet_enable_iptables_util_chains
    #- kubelet_enable_streaming_connections
