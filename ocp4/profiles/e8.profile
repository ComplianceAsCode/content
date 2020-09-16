documentation_complete: true

metadata:
    SMEs:
        - shaneboulden

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/essential-eight-linux-environments

title: 'Australian Cyber Security Centre (ACSC) Essential Eight'

description: |-
    This profile contains configuration checks for Red Hat OpenShift Container Platform
    that align to the Australian Cyber Security Centre (ACSC) Essential Eight.

    A copy of the Essential Eight in Linux Environments guide can be found at the
    ACSC website:

    https://www.cyber.gov.au/publications/essential-eight-in-linux-environments

selections:
    - ocp_idp_no_htpasswd
    - ocp_allowed_registries_for_import
    - ocp_allowed_registries
