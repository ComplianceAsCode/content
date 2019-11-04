documentation_complete: true

title: 'Open Computing Information Security Profile for OpenShift Node'

description: |-
    This baseline was inspired by the Center for Internet Security
    (CIS) Kubernetes Benchmark, v1.2.0 - 01-31-2017.

    For the ComplianceAsCode project to remain in compliance with
    CIS' terms and conditions, specifically Restrictions(8), note
    there is no representation or claim that the OpenCIS profile will
    ensure a system is in compliance or consistency with the CIS
    baseline.

selections:
    - service_auditd_enabled
    - selinux_state
    - accounts_password_all_shadowed