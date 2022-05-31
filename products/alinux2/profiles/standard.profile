documentation_complete: true

title: 'Standard System Security Profile for Alibaba Cloud Linux 2'

description: |-
    This profile contains rules to ensure standard security baseline
    of a Alibaba Cloud Linux 2 system. Regardless of your system's workload
    all of these checks should pass.

selections:
    - aide_build_database
    - ensure_gpgcheck_globally_activated
    - ensure_gpgcheck_never_disabled
    - rpm_verify_permissions
    - rpm_verify_hashes
    - service_firewalld_enabled
    - set_firewalld_default_zone
    - grub2_audit_argument
    - audit_rules_login_events
    - audit_rules_unsuccessful_file_modification
    - audit_rules_file_deletion_events
    - audit_rules_kernel_module_loading
    - grub2_nousb_argument
    - service_chronyd_or_ntpd_enabled
    - chronyd_or_ntpd_specify_remote_server
    - configure_ssh_crypto_policy
    - configure_libreswan_crypto_policy
    - configure_openssl_crypto_policy
    - configure_kerberos_crypto_policy
    - configure_bind_crypto_policy
    - configure_crypto_policy
    - package_openldap-clients_removed
    - service_autofs_disabled
    - service_abrtd_disabled
    - service_ntpdate_disabled
    - service_oddjobd_disabled
    - service_qpidd_disabled
    - service_rdisc_disabled
    - service_atd_disabled
