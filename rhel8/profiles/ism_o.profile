documentation_complete: true

metadata:
    SMEs:
        - shaneboulden
        - wcushen
        - ahamilto156

reference: https://www.cyber.gov.au/ism

title: 'Australian Cyber Security Centre (ACSC) ISM Official'

description: |-
  This profile contains configuration checks for Red Hat Enterprise Linux 8
  that align to the Australian Cyber Security Centre (ACSC) Information Security Manual (ISM)
  with the applicability marking of OFFICIAL.

  The ISM uses a risk-based approach to cyber security. This profile provides a guide to aligning 
  Red Hat Enterprise Linux security controls with the ISM, which can be used to select controls 
  specific to an organisation's security posture and risk profile.

  A copy of the ISM can be found at the ACSC website:

  https://www.cyber.gov.au/ism

extends: e8

selections:

  ## Operating system configuration
  ## Identifiers 1491
  - no_shelllogin_for_systemaccounts

  ## Local administrator accounts
  ## Identifiers 1382 / 1410
  - accounts_password_all_shadowed
  - package_sudo_installed

  ## Content filtering & Anti virus
  ## Identifiers  0576 / 1341 / 1034 / 1417 / 1288
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
  ## 1561 / 1546 / 0421 / 1557 / 0422 / 1558 / 1403 / 0431
  - sshd_max_auth_tries_value=5
  - disable_host_auth
  - require_emergency_target_auth
  - require_singleuser_auth
  - sshd_disable_kerb_auth
  - sshd_set_max_auth_tries

  ## Password authentication & Protecting credentials
  ## Identifiers 0421 / 0431 / 0418 / 1402
  - var_password_pam_minlen=14
  - var_accounts_password_warn_age_login_defs=7
  - var_accounts_minimum_age_login_defs=1
  - var_accounts_maximum_age_login_defs=60
  - accounts_password_warn_age_login_defs
  - accounts_maximum_age_login_defs
  - accounts_minimum_age_login_defs
  - accounts_passwords_pam_faillock_interval
  - accounts_passwords_pam_faillock_unlock_time
  - accounts_passwords_pam_faillock_deny
  - accounts_passwords_pam_faillock_deny_root
  - accounts_password_pam_minlen

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
  ## Identifiers 0580 / 0584 / 0582 / 0585 / 0586 / 0846 / 0957
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
  ## Identifiers 1055 / 1311 
  - network_nmcli_permissions
  - service_snmpd_disabled
  - snmpd_use_newer_protocol

  ## Wireless networks
  ## Identifiers 1315
  - wireless_disable_interfaces

  ## ASD Approved Cryptographic Algorithms
  ## Identifiers 0471 / 0472 / 0473 / 0474 / 0475 / 0476 / 0477 / 
  ## 0479 / 0480 / 0481 / 0489 / 0497 / 0994 / 0998 / 1001 /  1139 / 
  ## 1372 / 1373 / 1374 / 1375
  - enable_fips_mode
  - var_system_crypto_policy=fips
  - configure_crypto_policy

  ## Secure Shell access
  ## Identifiers 0484 / 1506 / 1449 / 0487
  - sshd_allow_only_protocol2
  - sshd_enable_warning_banner
  - sshd_disable_x11_forwarding
  - file_permissions_sshd_private_key
