documentation_complete: true

metadata:
    SMEs:
        - JAORMX
        - mrogers950
        - carlosmmatos

reference: https://nvd.nist.gov/800-53/Rev4/impact/moderate

title: 'NIST 800-53 Moderate-Impact Baseline for Red Hat OpenShift'

platform: ocp4

description: |-
    This compliance profile reflects the core set of Moderate-Impact Baseline
    configuration settings for deployment of Red Hat OpenShift Container
    Platform into U.S. Defense, Intelligence, and Civilian agencies.
    Development partners and sponsors include the U.S. National Institute
    of Standards and Technology (NIST), U.S. Department of Defense,
    the National Security Agency, and Red Hat.

    This baseline implements configuration requirements from the following
    sources:

    - NIST 800-53 control selections for Moderate-Impact systems (NIST 800-53)

    For any differing configuration requirements, e.g. password lengths, the stricter
    security setting was chosen. Security Requirement Traceability Guides (RTMs) and
    sample System Security Configuration Guides are provided via the
    scap-security-guide-docs package.

    This profile reflects U.S. Government consensus content and is developed through
    the ComplianceAsCode initiative, championed by the National
    Security Agency. Except for differences in formatting to accommodate
    publishing processes, this profile mirrors ComplianceAsCode
    content as minor divergences, such as bugfixes, work through the
    consensus and release processes.

selections:
    - ocp_idp_no_htpasswd
    - ocp_allowed_registries_for_import
    - ocp_allowed_registries
    - audit_log_forwarding_enabled
