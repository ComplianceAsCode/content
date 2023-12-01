documentation_complete: true

platform: ocp4-node

metadata:
    version: V1R1
    SMEs:
        - jhrozek
        - Vincent056
        - mrogers950
        - rhmdnd
        - david-rh

reference: https://public.cyber.mil/stigs/downloads/

title: 'DISA STIG for Red Hat OpenShift Container Platform 4 - Node level'

description: |-
    This profile contains configuration checks that align to the DISA STIG for
    Red Hat OpenShift Container Platform 4.

filter_rules: '"ocp4-node" in platforms or "ocp4-master-node" in platforms or "ocp4-node-on-sdn" in platforms or "ocp4-node-on-ovn" in platforms'

selections:
    - srg_ctr:all
