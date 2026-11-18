---
documentation_complete: true

metadata:
    SMEs:
        - marcusburghardt

reference: https://www.ccn-cert.cni.es/pdf/guias/series-ccn-stic/guias-de-acceso-publico-ccn-stic/6768-ccn-stic-610a22-perfilado-de-seguridad-red-hat-enterprise-linux-9-0/file.html

title: 'Centro Criptológico Nacional (CCN) - STIC for AlmaLinux OS 9 - Intermediate'

description: |-
    This profile defines a baseline that aligns with the "Intermediate" configuration of the
    CCN-STIC-610A22 Guide issued by the National Cryptological Center of Spain in 2022-10.

    The CCN-STIC-610A22 guide is written for Red Hat Enterprise Linux 9 and includes
    hardening settings at basic, intermediate, and advanced levels. There is no CCN-STIC
    guide for AlmaLinux OS 9: this profile is a copy of the Red Hat Enterprise Linux 9
    one, applying the same settings to AlmaLinux OS 9 as a binary-compatible rebuild.

selections:
    - ccn_almalinux9:all:intermediate
