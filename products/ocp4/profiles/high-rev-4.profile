documentation_complete: true

metadata:
    version: Revision 4
    SMEs:
        - JAORMX
        - mrogers950
        - jhrozek

reference: https://csrc.nist.gov/Projects/risk-management/sp800-53-controls/release-search#!/controls?version=5.1&security_baseline=High

title: 'NIST 800-53 High-Impact Baseline for Red Hat OpenShift - Platform level'

platform: ocp4

description: |-
    This compliance profile reflects the core set of High-Impact Baseline
    configuration settings for deployment of Red Hat OpenShift Container
    Platform into U.S. Defense, Intelligence, and Civilian agencies.
    Development partners and sponsors include the U.S. National Institute
    of Standards and Technology (NIST), U.S. Department of Defense,
    the National Security Agency, and Red Hat.

    This baseline implements configuration requirements from the following
    sources:

    - NIST 800-53 control selections for High-Impact systems (NIST 800-53)

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

filter_rules: '"ocp4-node" not in platforms and "ocp4-master-node" not in platforms and "ocp4-node-on-sdn" not in platforms and "ocp4-node-on-ovn" not in platforms'

# CM-6 CONFIGURATION SETTINGS
# CM-6(1) CONFIGURATION SETTINGS | AUTOMATED CENTRAL MANAGEMENT / APPLICATION / VERIFICATION
extends: cis

selections:
    - nist_ocp4:all:high
  ### Helper Rules
  ### This is a helper rule to fetch the required api resource for detecting OCP version
    - version_detect_in_ocp
    - version_detect_in_hypershift
