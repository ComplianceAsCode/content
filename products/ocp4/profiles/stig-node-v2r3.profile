---
documentation_complete: true

platform: ocp4-node
status: deprecated

metadata:
    version: V2R3
    SMEs:
        - Vincent056
        - rhmdnd
        - yuumasato

reference: https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_RH_OpenShift_Container_Platform_4-x_V2R3_STIG.zip

title: 'DISA STIG for Red Hat OpenShift Container Platform 4 - Node level'

description: |-
    This profile contains configuration checks that align to the DISA STIG for
    Red Hat OpenShift Container Platform 4.

# Kubevirt rules were added to STIG control in V2R6 and are scanned by the stig-vm-extension CEL profile
filter_rules: '("ocp4-node" in platform or "ocp4-master-node" in platform or "ocp4-node-on-sdn" in platform
    or "ocp4-node-on-ovn" in platform) and "kubevirt" not in id_'

selections:
    - stig_ocp4:all
