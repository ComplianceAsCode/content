documentation_complete: true

title: 'VPP - Protection Profile for Virtualization v. 1.0 for Red Hat Enterprise Linux Hypervisor (RHELH)'

description: |-
    This compliance profile reflects the core set of security
    related configuration settings for deployment of Red Hat Enterprise
    Linux Hypervisor (RHELH) 7.x into U.S. Defense, Intelligence, and Civilian agencies.
    Development partners and sponsors include the U.S. National Institute
    of Standards and Technology (NIST), U.S. Department of Defense,
    the National Security Agency, and Red Hat.

    This baseline implements configuration requirements from the following
    sources:

    - Committee on National Security Systems Instruction No. 1253 (CNSSI 1253)
    - NIST 800-53 control selections for MODERATE impact systems (NIST 800-53)
    - U.S. Government Configuration Baseline (USGCB)
    - NIAP Protection Profile for Virtualization v1.0 (VPP v1.0)

    For any differing configuration requirements, e.g. password lengths, the stricter
    security setting was chosen. Security Requirement Traceability Guides (RTMs) and
    sample System Security Configuration Guides are provided via the
    scap-security-guide-docs package.

    This profile reflects U.S. Government consensus content and is developed through
    the ComplianceAsCode project, championed by the National
    Security Agency. Except for differences in formatting to accommodate
    publishing processes, this profile mirrors ComplianceAsCode
    content as minor divergences, such as bugfixes, work through the
    consensus and release processes.

extends: ospp

selections: []
