documentation_complete: true

platform: ocp4-node

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

filter_rules: '"ocp4-node" in platforms or "ocp4-master-node" in platforms or "ocp4-node-on-sdn" in platforms or "ocp4-node-on-ovn" in platforms'

# Req-2.2
extends: cis-node

selections:
    - pcidss_ocp4:all:base
