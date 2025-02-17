documentation_complete: true

platform: ocp4

metadata:
    version: V2R2
    SMEs:
        - Vincent056
        - rhmdnd
        - yuumasato

reference: https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_RH_OpenShift_Container_Platform_4-12_V2R2_STIG.zip

title: 'DISA STIG for Red Hat OpenShift Container Platform 4 - Platform level'

description: |-
    This profile contains configuration checks that align to the DISA STIG for
    Red Hat OpenShift Container Platform 4.

filter_rules: '"ocp4-node" not in platforms and "ocp4-master-node" not in platforms and "ocp4-node-on-sdn" not in platforms and "ocp4-node-on-ovn" not in platforms'

selections:
    - stig_ocp4:all
  ### Variables
    - var_openshift_audit_profile=WriteRequestBodies
    - var_oauth_token_maxage=8h
  ### Helper Rules
  ### This is a helper rule to fetch the required api resource for detecting OCP version
    - version_detect_in_ocp
    - version_detect_in_hypershift
