description: "Draft profile for ANSSI compliance at the minimal level. ANSSI stands\
    \ for Agence nationale de la s\xE9curit\xE9 des syst\xE8mes d'information. Based\
    \ on https://www.ssi.gouv.fr/."
documentation_complete: true
selections:
- ensure_gpgcheck_globally_activated
- ensure_gpgcheck_local_packages
- ensure_gpgcheck_never_disabled
- ensure_redhat_gpgkey_installed
- package_dhcp_removed
- package_rsyslog_installed
- package_sendmail_removed
- package_telnetd_removed
- security_patches_up_to_date
- service_rsyslog_enabled
- set_password_hashing_algorithm_logindefs
- sudo_remove_no_authenticate
- sudo_remove_nopasswd
title: DRAFT - ANSSI DAT-NT28 (minimal)
