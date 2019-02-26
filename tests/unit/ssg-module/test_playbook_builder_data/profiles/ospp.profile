documentation_complete: true

title: 'OSPP - Protection Profile for General Purpose Operating Systems'

description: |-
    This profile reflects mandatory configuration controls identified in the
    NIAP Configuration Annex to the Protection Profile for General Purpose
    Operating Systems (Protection Profile Version 4.2).

    As Fedora OS is moving target, this profile does not guarantee to provide
    security levels required from US National Security Systems. Main goal of
    the profile is to provide Fedora developers with hardened environment
    similar to the one mandated by US National Security Systems.

selections:
    - selinux_state
    - var_selinux_state=enforcing
    - package_abrt_removed
    - configure_crypto_policy
