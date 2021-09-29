documentation_complete: true

title: 'NIST 800-53 Moderate-Impact Baseline for Red Hat OpenShift - Node level'

platform: ocp4-node

metadata:
    SMEs:
        - JAORMX
        - mrogers950
        - jhrozek

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

# CM-6 CONFIGURATION SETTINGS
# CM-6(1) CONFIGURATION SETTINGS | AUTOMATED CENTRAL MANAGEMENT / APPLICATION / VERIFICATION
extends: cis-node

selections:

    # AU-4
    - partition_for_var_log_kube_apiserver
    - partition_for_var_log_openshift_apiserver
    - partition_for_var_log_oauth_apiserver

    # AU-9
    - directory_access_var_log_kube_audit
    - directory_permissions_var_log_kube_audit
    - file_ownership_var_log_kube_audit
    - file_permissions_var_log_kube_audit
    - directory_access_var_log_ocp_audit
    - directory_permissions_var_log_ocp_audit
    - file_ownership_var_log_ocp_audit
    - file_permissions_var_log_ocp_audit
    - directory_access_var_log_oauth_audit
    - directory_permissions_var_log_oauth_audit
    - file_ownership_var_log_oauth_audit
    - file_permissions_var_log_oauth_audit

    # CM-5(3)
    # CM-7(2)
    # CM-7(5)
    # CM-11
    # SA-10(1)
    - reject_unsigned_images_by_default