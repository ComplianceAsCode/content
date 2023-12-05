documentation_complete: true

metadata:
    version: '4.0'
    SMEs:
        - marcusburghardt
        - mab879
        - vojtapolasek

reference: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0.pdf

title: 'PCI-DSS v4.0 Control Baseline for Red Hat Enterprise Linux 7'

description: |-
    Payment Card Industry - Data Security Standard (PCI-DSS) is a set of
    security standards designed to ensure the secure handling of payment card
    data, with the goal of preventing data breaches and protecting sensitive
    financial information.

    This profile ensures Red Hat Enterprise Linux 7 is configured in alignment
    with PCI-DSS v4.0 requirements.

selections:
    - pcidss_4:all
    # More tests are needed to identify which rule is conflicting with rpm_verify_permissions.
    # https://github.com/ComplianceAsCode/content/issues/11285
    - '!rpm_verify_permissions'
    # these rules do not apply to RHEL but they have to keep the prodtype for historical reasons
    - '!package_audit-audispd-plugins_installed'
    - '!service_ntp_enabled'
    - '!set_ipv6_loopback_traffic'
    - '!set_loopback_traffic'
    - '!timer_logrotate_enabled'
