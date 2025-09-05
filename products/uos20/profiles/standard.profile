documentation_complete: true

title: 'Standard System Security Profile for UnionTech OS Server 20'

description: |-
    This profile contains rules to ensure standard security baseline
    of a UnionTech OS Server 20 system. Regardless of your system's workload
    all of these checks should pass.

selections:
    - ensure_gpgcheck_globally_activated
    - ensure_redhat_gpgkey_installed
    - rpm_verify_permissions
    - rpm_verify_hashes
    - security_patches_up_to_date
    - file_permissions_unauthorized_sgid
    - file_permissions_unauthorized_suid
    - audit_rules_file_deletion_events
    - service_abrtd_disabled
    - service_atd_disabled
    - service_autofs_disabled
    - service_ntpdate_disabled
    - service_oddjobd_disabled
    - service_qpidd_disabled
    - service_rdisc_disabled
    - configure_crypto_policy
    - configure_bind_crypto_policy
    - configure_openssl_crypto_policy
    - configure_libreswan_crypto_policy
    - configure_ssh_crypto_policy
    - configure_kerberos_crypto_policy
