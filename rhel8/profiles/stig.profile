documentation_complete: true

metadata:
    version: V1R0.1-Draft
    SMEs:
        - carlosmmatos

reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: '[DRAFT] DISA STIG for Red Hat Enterprise Linux 8'

description: |-
    This profile contains configuration checks that align to the
    [DRAFT] DISA STIG for Red Hat Enterprise Linux 8.

    In addition to being applicable to Red Hat Enterprise Linux 8, DISA recognizes this
    configuration baseline as applicable to the operating system tier of
    Red Hat technologies that are based on Red Hat Enterprise Linux 8, such as:

    - Red Hat Enterprise Linux Server
    - Red Hat Enterprise Linux Workstation and Desktop
    - Red Hat Enterprise Linux for HPC
    - Red Hat Storage
    - Red Hat Containers with a Red Hat Enterprise Linux 8 image

extends: ospp

selections:
    - login_banner_text=dod_banners
    - dconf_db_up_to_date
    - dconf_gnome_banner_enabled
    - dconf_gnome_login_banner_text
    - banner_etc_issue
    - accounts_password_set_min_life_existing
    - accounts_password_set_max_life_existing
    - account_disable_post_pw_expiration
    - account_temp_expire_date
    - audit_rules_usergroup_modification_passwd
    - sssd_enable_smartcards
    - sssd_offline_cred_expiration
    - smartcard_configure_cert_checking
    - encrypt_partitions
    - sysctl_net_ipv4_tcp_syncookies
    - clean_components_post_updating
    - package_audispd-plugins_installed
    - package_libcap-ng-utils_installed
    - auditd_audispd_syslog_plugin_activated
    - accounts_passwords_pam_faillock_enforce_local
    - accounts_password_pam_enforce_local
    - accounts_password_pam_enforce_root

    # Configure TLS for remote logging
    - package_rsyslog_installed
    - package_rsyslog-gnutls_installed
    - rsyslog_remote_tls
    - rsyslog_remote_tls_cacert

    # Unselect zIPL rules from OSPP
    - "!zipl_bls_entries_only"
    - "!zipl_bootmap_is_up_to_date"
    - "!zipl_audit_argument"
    - "!zipl_audit_backlog_limit_argument"
    - "!zipl_page_poison_argument"
    - "!zipl_slub_debug_argument"
    - "!zipl_vsyscall_argument"
    - "!zipl_vsyscall_argument.role=unscored"
    - "!zipl_vsyscall_argument.severity=info"
