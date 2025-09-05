documentation_complete: true

title: '[DRAFT] DISA STIG for Red Hat Enterprise Linux CoreOS'

description: |-
    This profile contains configuration checks that align to the
    [DRAFT] DISA STIG for Red Hat Enterprise Linux CoreOS which
    is the operating system layer of Red Hat OpenShift Container
    Platform.

extends: ospp

selections:
    - login_banner_text=dod_banners
    - banner_etc_issue
    - audit_rules_usergroup_modification_passwd
    - sssd_enable_smartcards
    - sssd_offline_cred_expiration
    - encrypt_partitions
    - accounts_tmout
    - sudo_remove_no_authenticate
    - sudo_remove_nopasswd
    - sudo_require_authentication
