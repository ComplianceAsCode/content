documentation_complete: true

platform: ocp4

metadata:
    version: 4.0.0
    SMEs:
        - rhmdnd
        - Vincent056
        - yummasato

reference: https://www.pcisecuritystandards.org/document_library/

title: 'PCI-DSS v4.0.0 Control Baseline for Red Hat OpenShift Container Platform 4'

description: |-
    Ensures PCI-DSS v4.0.0 security configuration settings are applied.

filter_rules: '"ocp4-node" not in platforms and "ocp4-master-node" not in platforms'

# Req-2.2
extends: cis

selections:
    - pcidss_4_ocp4:all:base
  ### Helper Rules
  ### This is a helper rule to fetch the required api resource for detecting OCP version
    - version_detect_in_ocp
    - version_detect_in_hypershift
