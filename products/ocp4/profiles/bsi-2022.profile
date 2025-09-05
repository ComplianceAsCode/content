---
documentation_complete: true

title: 'BSI IT-Grundschutz (Basic Protection) Building Block SYS.1.6 and APP.4.4'

platform: ocp4

reference: https://www.bsi.bund.de/SharedDocs/Downloads/EN/BSI/Grundschutz/International/bsi_it_gs_comp_2022.pdf

metadata:
    SMEs:
        - ermeratos
        - benruland
        - oliverbutanowitz
        - sluetze
    version: 2022

description: |-
    This profile defines a baseline that aligns to the BSI (Federal Office for Security Information) IT-Grundschutz
    Basic-Protection.

    This baseline implements configuration requirements from the following
    sources:

    - Building-Block SYS.1.6 Containerisation
    - Building-Block APP.4.4 Kubernetes

filter_rules: '"ocp4-node" not in platform and "ocp4-master-node" not in platform and "ocp4-node-on-sdn"
    not in platform and "ocp4-node-on-ovn" not in platform'

selections:
    - bsi_app_4_4:all
    - bsi_sys_1_6:all
    ### Helper Rules
    ### This is a helper rule to fetch the required api resource for detecting OCP version
    - version_detect_in_ocp
    - version_detect_in_hypershift
    # variables
    - var_apiserver_tls_cipher_suites=2024-01-BSI-TR-02102-2
    - var_apiserver_tls_cipher_suites_regex=2024-01-BSI-TR-02102-2
    - var_etcd_tls_cipher_suites_regex=2024-01-BSI-TR-02102-2
    - var_ingresscontroller_tls_cipher_suites_regex=2024-01-BSI-TR-02102-2
    - var_ingresscontroller_tls_cipher_suites=2024-01-BSI-TR-02102-2
    # to ensure that the cipher suites are used across all components, additional tests, which are not
    # required in the control files for SYS.1.6 and APP.4.4, need to be added
    # apiserver_tls_cipher_suites and kubelet_tls_cipher_suites are not needed, as they are covered by the
    # controls for SYS.1.6 and APP.4.4
    - ingress_controller_tls_cipher_suites
    - etcd_check_cipher_suite