documentation_complete: true

metadata:
    version: '4.0'
    SMEs:
        - hustliyilin
        - rain-Qing

reference: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0.pdf

title: 'PCI-DSS v4.0 Control Baseline for Alibaba Cloud Linux 2'

description: |-
    Payment Card Industry - Data Security Standard (PCI-DSS) is a set of
    security standards designed to ensure the secure handling of payment card
    data, with the goal of preventing data breaches and protecting sensitive
    financial information.

selections:
    - pcidss_4:all
    - '!rpm_verify_permissions'
    - '!package_audit-audispd-plugins_installed'
    - '!service_ntp_enabled'
    - '!set_ipv6_loopback_traffic'
    - '!set_loopback_traffic'
    - '!timer_logrotate_enabled'
    - '!ensure_redhat_gpgkey_installed'
