---
documentation_complete: true

metadata:
    version: V2R6
    SMEs:
        - Vincent056
        - rhmdnd
        - yuumasato
        - abushkin-redhat

reference: https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_RH_OpenShift_Container_Platform_4-x_V2R6_STIG.zip

title: 'DISA STIG for Red Hat OpenShift Container Platform 4 - Virtualization Extension'

description: |-
    This profile contains CEL-based checks for OpenShift Virtualization
    that align to the DISA STIG for Red Hat OpenShift Container Platform 4.

scanner_type: CEL

# Exclude node kubevirt rules — those are automated in the stig-node XCCDF profile
filter_rules: '"kubevirt" in id_ and "ocp4-node" not in platforms'

selections:
    - stig_ocp4:all
