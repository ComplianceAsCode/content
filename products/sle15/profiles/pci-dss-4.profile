documentation_complete: true

metadata:
    SMEs:
        - abergmann

reference: https://docs-prv.pcisecuritystandards.org/PCI%20DSS/Standard/PCI-DSS-v4_0.pdf

title: 'PCI-DSS v4 Control Baseline for SUSE Linux enterprise 15'

description: |-
    Ensures PCI-DSS v4 security configuration settings are applied.

selections:
    -  pcidss_4:all:base
    -  ensure_pam_wheel_group_empty
    -  sshd_strong_kex=pcidss
    -  sshd_approved_macs=cis_sle15
    -  sshd_approved_ciphers=cis_sle15 
    -  var_multiple_time_servers=suse
    -  var_multiple_time_pools=suse      
# Exclude from PCI DISS profile all rules related to ntp and timesyncd and keep only 
# rules related to chrony
    - '!ntpd_specify_multiple_servers'
    - '!ntpd_specify_remote_server'
    - '!service_ntp_enabled'
    - '!service_ntpd_enabled'
    - '!service_timesyncd_enabled'
    - '!package_libreswan_installed'
    - '!use_pam_wheel_for_su'
    -  use_pam_wheel_group_for_su
    -  var_pam_wheel_group_for_su=cis
    # Following rules once had a prodtype incompatible with the sle15 product
    - '!aide_periodic_cron_checking'
    - '!accounts_password_pam_dcredit'
    - '!dconf_gnome_screensaver_lock_delay'
    - '!accounts_password_pam_pwhistory_remember_system_auth'
    - '!sysctl_kernel_core_pattern'
    - '!configure_firewalld_ports'
    - '!accounts_passwords_pam_faillock_deny'
    - '!file_owner_user_cfg'
    - '!accounts_passwords_pam_faillock_unlock_time'
    - '!ensure_redhat_gpgkey_installed'
    - '!firewalld_loopback_traffic_restricted'
    - '!accounts_password_pam_lcredit'
    - '!file_group_ownership_var_log_audit'
    - '!package_ftp_removed'
    - '!gnome_gdm_disable_guest_login'
    - '!accounts_password_pam_minlen'
    - '!no_password_auth_for_systemaccounts'
    - '!auditd_name_format'
    - '!file_groupowner_user_cfg'
    - '!directory_access_var_log_audit'
    - '!ensure_root_password_configured'
    - '!gnome_gdm_disable_automatic_login'
    - '!accounts_password_pam_pwhistory_remember_password_auth'
    - '!enable_authselect'
    - '!file_permissions_user_cfg'
    - '!package_audispd-plugins_installed'
    - '!dconf_gnome_disable_automount'
    - '!firewalld_loopback_traffic_trusted'
    - '!dconf_gnome_disable_automount_open'
    - '!network_nmcli_permissions'
    - '!package_cryptsetup-luks_installed'
