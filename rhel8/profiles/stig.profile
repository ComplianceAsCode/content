documentation_complete: true

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
    - dconf_gnome_banner_enabled
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

    # Configure TLS for remote logging
    - package_rsyslog_installed
    - package_rsyslog-gnutls_installed
    - rsyslog_remote_tls
    - rsyslog_remote_tls_cacert
