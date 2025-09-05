documentation_complete: false

platform: ocp4

metadata:
    SMEs:
        - jhrozek
        - Vincent056
        - mrogers950
        - rhmdnd
        - david-rh

reference: https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_Container_Platform_V1R3_SRG.zip

title: '[DRAFT] DISA STIG for Red Hat OpenShift Container Platform 4 - Platform level'

description: |-
    This is a draft profile for experimental purposes. It is not based on the 
    DISA STIG for OCP4, because one was not available at the time yet. This 
    profile contains configuration checks that align to the DISA STIG for 
    Red Hat OpenShift Container Platform 4.

filter_rules: '"ocp4-node" not in platforms and "ocp4-master-node" not in platforms and "ocp4-node-on-sdn" not in platforms and "ocp4-node-on-ovn" not in platforms'

selections:
    - srg_ctr:all
