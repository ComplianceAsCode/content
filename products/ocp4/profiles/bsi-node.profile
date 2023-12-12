documentation_complete: true

title: 'BSI IT-Grundschutz (Basic Protection) Building Block SYS.1.6 and APP.4.4'

platform: ocp4-node

reference: https://www.bsi.bund.de/SharedDocs/Downloads/EN/BSI/Grundschutz/International/bsi_it_gs_comp_2022.pdf

metadata:
    SMEs:
        - ermeratos
        - benruland
        - oliverbutanowitz
        - sluetze
    version: 2022

description: |-
    This profile defines a baseline that aligns to the BSI (Federal Office for Security Information) IT-Grundschutz
    Basic-Protection.

    This baseline implements configuration requirements from the following
    sources:

    - Building-Block SYS.1.6 Containerisation
    - Building-Block APP.4.4 Kubernetes


filter_rules: '"ocp4-node" in platforms or "ocp4-master-node" in platforms or "ocp4-node-on-sdn" in platforms or "ocp4-node-on-ovn" in platforms'

selections:
    - bsi_app_4_4:all
