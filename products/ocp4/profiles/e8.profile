documentation_complete: true

metadata:
    SMEs:
        - shaneboulden
        - tjbutt58

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

title: 'Australian Cyber Security Centre (ACSC) Essential Eight'

platform: ocp4

description: |-
    This profile contains configuration checks for Red Hat OpenShift Container Platform
    that align to the Australian Cyber Security Centre (ACSC) Essential Eight.

    A copy of the Essential Eight in Linux Environments guide can be found at the
    ACSC website:

    https://www.cyber.gov.au/acsc/view-all-content/publications/hardening-linux-workstations-and-servers

selections:
    - ocp_idp_no_htpasswd
    - ocp_allowed_registries_for_import
    - ocp_allowed_registries
    - scc_limit_privileged_containers
    - scc_limit_privilege_escalation
    - scc_limit_root_containers
    - scc_limit_container_allowed_capabilities
    - rbac_pod_creation_access
    - rbac_wildcard_use
    - rbac_limit_cluster_admin
    - api_server_tls_cipher_suites
    - api_server_encryption_provider_cipher
  ### Helper Rules
  ### This is a helper rule to fetch the required api resource for detecting OCP version
    - version_detect_in_ocp
    - version_detect_in_hypershift
