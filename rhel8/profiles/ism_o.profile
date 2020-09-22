documentation_complete: true

metadata:
    SMEs:
        - shaneboulden
        - wcushen
        - ahamilto156

reference: https://www.cyber.gov.au/acsc/view-all-content/publications/essential-eight-linux-environments

title: 'Australian Cyber Security Centre (ACSC) Information Security Manual (ISM) Official'

description: |-
  This profile contains configuration checks for Red Hat Enterprise Linux 8
  that align to the Australian Cyber Security Centre (ACSC) Information Security Manual (ISM)
  with the Attorney-General’s Department (AGD)’s applicability marking of OFFICIAL.

  A overview and list of Cyber security guidelines of the 
  Information Security Manual can be found at the ACSC website:

  https://www.cyber.gov.au/ism

extends: e8

selections:

  ## Operating system configuration
  ## Identifiers 1491
  - no_shelllogin_for_systemaccounts

  ## Local administrator accounts
  ## Identifiers 1410
  - accounts_password_all_shadowed

  ## Content filtering & Anti virus
  ## Identifiers 1341 / 1034 / 1417 / 1288
  - package_aide_installed

  ## Software firewall
  ## Identifiers 1416
  - configure_firewalld_ports
  ## Removing due to build error
  ## - configure_firewalld_rate_limiting
  - firewalld_sshd_port_enabled
  - set_firewalld_default_zone

  ## Endpoint device control software
  ## Identifiers 1418
  - package_usbguard_installed
  - service_usbguard_enabled

  ## Authentication hardening
  ## Identifiers 1546 / 0974 / 1173 / 1504 / 1505 / 1401 / 1559 / 1560
  ## 1561 / 0421 / 1557 / 0422 / 1558 / 1403 / 0431
  - disable_host_auth
  - require_emergency_target_auth
  - require_singleuser_auth
  - sebool_authlogin_nsswitch_use_ldap
  - sebool_authlogin_radius
  - sshd_disable_kerb_auth
  - sshd_set_max_auth_tries
  - sssd_enable_smartcards
  - accounts_password_minlen_login_defs
  - var_password_pam_minlen=14
  - accounts_password_pam_minlen
  - accounts_password_pam_minclass
  - accounts_password_pam_dcredit
  - accounts_password_pam_lcredit
  - accounts_password_pam_ocredit
  - accounts_password_pam_ucredit
  - accounts_password_pam_maxrepeat
  - accounts_passwords_pam_faillock_deny
  - accounts_passwords_pam_faillock_deny_root
  - accounts_passwords_pam_faillock_interval
  - accounts_passwords_pam_faillock_unlock_time

  ## Password authentication & Protecting credentials
  ## Identifiers 1055 / 0418 / 1402
  - network_nmcli_permissions
  - configure_kerberos_crypto_policy
  - kerberos_disable_no_keytab
  - sebool_kerberos_enabled
  - sshd_disable_gssapi_auth
  - enable_ldap_client
  - set_password_hashing_algorithm_libuserconf
  - set_password_hashing_algorithm_logindefs
  - set_password_hashing_algorithm_systemauth
  - accounts_password_warn_age_login_defs
  - accounts_maximum_age_login_defs
  - accounts_minimum_age_login_defs
 
  ## System administration & MFA
  ## Identifiers 1382 / 1384 / 1386
  - package_sudo_installed
  - package_opensc_installed
  - var_smartcard_drivers=cac
  - configure_opensc_card_drivers
  - force_opensc_card_drivers
  - package_pcsc-lite_installed
  - service_pcscd_enabled
  - sssd_enable_smartcards

  ## System patching & Applicatoin versions
  ## Identifiers 1493 / 1144 / 0940 / 1472 / 1494 / 1495 / 1467 / 1483 
  - dnf-automatic_apply_updates
  - package_dnf-plugin-subscription-manager_installed
  - package_subscription-manager_installed

  ## Centralised logging facility
  ## Identifiers 1405 / 0988 
  - rsyslog_cron_logging
  - rsyslog_files_groupownership
  - rsyslog_files_ownership
  - rsyslog_files_permissions
  - rsyslog_nolisten
  - rsyslog_remote_loghost
  - rsyslog_remote_tls
  - rsyslog_remote_tls_cacert
  - package_chrony_installed
  - service_chronyd_enabled
  - chronyd_or_ntpd_specify_multiple_servers
  - chronyd_specify_remote_server
  - service_chronyd_or_ntpd_enabled

  ## Events to be logged
  ## Identifiers 0584 / 0582 / 0585 / 0586 / 0846 / 0957
  - display_login_attempts
  - sebool_auditadm_exec_content
  - audit_rules_privileged_commands
  - audit_rules_session_events
  - audit_rules_unsuccessful_file_modification
  - audit_access_failed
  - audit_access_success

  ## Web application & Database servers
  ## Identifiers 1552 / 1277
  - openssl_use_strong_entropy

  ## Network design and configuration
  ## Identifiers 1311 
  - service_snmpd_disabled
  - snmpd_use_newer_protocol

  ## Wireless networks
  ## Identifiers 1315 / 1319
  - wireless_disable_interfaces
  - network_ipv6_static_address

  ## ASD Approved Cryptopgraphic Algorithims
  ## Identifiers 1446
  - enable_dracut_fips_module
  - enable_fips_mode
  - var_system_crypto_policy=fips
  - configure_crypto_policy

  ## Secure Shell access
  ## Identifiers 1506 / 1449 / 0487 
  - sshd_allow_only_protocol2
