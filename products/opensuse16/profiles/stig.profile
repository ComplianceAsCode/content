documentation_complete: true

reference: https://www.cyber.mil/stigs/downloads/

title: 'General Purpose Operating System Security Profile for openSUSE Leap 16'

description: |-
    General Purpose Operating System Security Profile for openSUSE Leap 16

selections:
    - srg_gpos:all
    - package_audit-audispd-plugins_installed
    - '!aide_periodic_cron_checking'
    - '!aide_verify_ext_attributes'
    - '!enable_fips_mode'
    - '!package_subscription-manager_installed'
