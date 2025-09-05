documentation_complete: true

platform: ocp4

metadata:
    version: V1R1
    SMEs:
        - jhrozek
        - Vincent056
        - mrogers950
        - rhmdnd
        - david-rh

reference: https://public.cyber.mil/stigs/downloads/

title: 'DISA STIG for Red Hat OpenShift Container Platform 4 - Platform level'

description: |-
    This profile contains configuration checks that align to the DISA STIG for
    Red Hat OpenShift Container Platform 4.

filter_rules: '"ocp4-node" not in platforms and "ocp4-master-node" not in platforms and "ocp4-node-on-sdn" not in platforms and "ocp4-node-on-ovn" not in platforms'

selections:
    - srg_ctr:all
  ### Variables
    - var_openshift_audit_profile=WriteRequestBodies
  ### Helper Rules
  ### This is a helper rule to fetch the required api resource for detecting OCP version
    - version_detect_in_ocp
    - version_detect_in_hypershift
