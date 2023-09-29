documentation_complete: true

platform: ocp4

metadata:
    version: 3.2.1
    SMEs:
        - JAORMX
        - jhrozek
        - mrogers950

reference: https://www.pcisecuritystandards.org/documents/PCI_DSS_v3-2-1.pdf

title: 'PCI-DSS v3.2.1 Control Baseline for Red Hat OpenShift Container Platform 4'

description: |-
    Ensures PCI-DSS v3.2.1 security configuration settings are applied.

filter_rules: '"ocp4-node" not in platforms and "ocp4-master-node" not in platforms'

# Req-2.2
extends: cis

selections:
    - pcidss_ocp4:all:base
  ### Helper Rules
  ### This is a helper rule to fetch the required api resource for detecting OCP version
    - version_detect_in_ocp
    - version_detect_in_hypershift
