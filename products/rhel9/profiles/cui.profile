documentation_complete: true

metadata:
    version: TBD
    SMEs:
        - carlosmmatos

title: 'Unclassified Information in Non-federal Information Systems and Organizations (NIST 800-171)'

description: |-
    From NIST 800-171, Section 2.2:
    Security requirements for protecting the confidentiality of CUI in nonfederal
    information systems and organizations have a well-defined structure that
    consists of:

    (i) a basic security requirements section;
    (ii) a derived security requirements section.

    The basic security requirements are obtained from FIPS Publication 200, which
    provides the high-level and fundamental security requirements for federal
    information and information systems. The derived security requirements, which
    supplement the basic security requirements, are taken from the security controls
    in NIST Special Publication 800-53.

    This profile configures Red Hat Enterprise Linux 8 to the NIST Special
    Publication 800-53 controls identified for securing Controlled Unclassified
    Information (CUI)."

extends: ospp

selections:
    - inactivity_timeout_value=10_minutes
