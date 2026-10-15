---
documentation_complete: true

metadata:
    version: TBD
    SMEs:
        - ggbecker

reference: https://csrc.nist.gov/pubs/sp/800/172/r3/final

title: 'Enhanced Security Requirements for Protecting Controlled Unclassified Information (NIST 800-172)'

description: |-
    From NIST 800-172, Section 1.1:
    This publication provides federal agencies with a set of recommended enhanced
    security requirements for protecting the confidentiality, integrity, and
    availability of CUI when such information is associated with a critical
    program or high value asset. The enhanced security requirements are designed
    to provide additional protection for CUI in nonfederal systems and
    organizations from the advanced persistent threat (APT) by promoting
    penetration-resistant architecture, damage-limiting operations, and cyber
    resiliency.

    The enhanced security requirements are implemented in addition to the
    security requirements in NIST SP 800-171, since those requirements are not
    designed to address the APT. This profile configures Red Hat Enterprise
    Linux 10 to the combined set of NIST SP 800-171 security requirements and
    NIST SP 800-172 enhanced security requirements for securing Controlled
    Unclassified Information (CUI) associated with a critical program or high
    value asset.

selections:
    - nist_800_171:all
    - nist_800_172:all
