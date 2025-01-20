documentation_complete: true

metadata:
    version: V1R1
    SMEs:
        - svet-se
        - rumch-se
        - teacup-on-rockingchair

reference:

title: 'Public Cloud Hardening for SUSE Linux Enterprise Micro (SLEM) 5'

description: |-
    This profile contains configuration checks to be used to harden
    SUSE Linux Enterprise Micro (SLEM) 5 for use with public cloud providers.
    
selections:
  - stig_slmicro5:all
  - '!permissions_local_var_log_audit'
  - '!ssh_private_keys_have_passcode'
  - '!set_password_hashing_algorithm_systemauth'
  - '!grub2_password'
  - '!grub2_uefi_password'
  - '!service_firewalld_enabled'
  - '!service_autofs_disabled'
  - '!account_emergency_admin'
  - '!account_temp_expire_date'
  - '!sshd_set_idle_timeout'
  - '!encrypt_partitions'
  - '!file_permissions_local_var_log_messages'
  - '!permissions_local_audit_binaries'
  - '!auditd_audispd_configure_sufficiently_large_partition'
  - '!sudo_require_authentication'
  - '!sudo_remove_nopasswd'
  - '!sudo_remove_no_authenticate'
  - '!sssd_memcache_timeout'
  - '!sssd_offline_cred_expiration'
  - '!is_fips_mode_enabled'
  - '!service_systemd-journal-upload_enabled'
  - '!package_systemd-journal-remote_installed'
  - '!security_patches_up_to_date'
  - '!accounts_authorized_local_users'
  - '!partition_for_var_log_audit'
  - '!accounts_user_home_paths_only'
  - '!mount_option_nosuid_remote_filesystems'
  - '!mount_option_noexec_remote_filesystems'
  - '!pam_disable_automatic_configuration'
  - '!gnome_gdm_disable_unattended_automatic_login'
  - '!sysctl_net_ipv4_conf_all_accept_redirects'
  - '!sysctl_net_ipv4_ip_forward'
  - '!selinux_user_login_roles'
