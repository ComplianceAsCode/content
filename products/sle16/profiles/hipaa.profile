---
documentation_complete: true

metadata:
    SMEs:
        - svet-se
        - teacup-on-rockingchair

reference: https://www.hhs.gov/hipaa/for-professionals/index.html

title: 'Health Insurance Portability and Accountability Act (HIPAA)'

description: |-
    The HIPAA Security Rule establishes U.S. national standards to protect individuals'
    electronic personal health information that is created, received, used, or
    maintained by a covered entity. The Security Rule requires appropriate
    administrative, physical and technical safeguards to ensure the
    confidentiality, integrity, and security of electronic protected health
    information.

    This profile contains configuration checks that align to the
    HIPPA Security Rule for SUSE Linux Enterprise 16

selections:
    - hipaa:all

    # Ensure audit_backlog_limit is sufficient
    - grub2_audit_backlog_limit_argument
    - var_audit_backlog_limit=8192

    - '!audit_rules_immutable'
    - '!audit_rules_login_events_tallylog'
    - '!audit_rules_privileged_commands_crontab'
    - '!audit_rules_privileged_commands_postdrop'
    - '!audit_rules_privileged_commands_postqueue'
    - '!audit_rules_privileged_commands_unix2_chkpwd'
    - '!coreos_audit_option'
    - '!coreos_disable_interactive_boot'
    - '!coreos_enable_selinux_kernel_argument'
    - '!coreos_nousb_kernel_argument'
    - '!enable_authselect'
    - '!ensure_almalinux_gpgkey_installed'
    - '!ensure_fedora_gpgkey_installed'
    - '!ensure_gpgcheck_repo_metadata'
    - '!ensure_redhat_gpgkey_installed'
    - '!file_groupowner_user_cfg'
    - '!file_owner_user_cfg'
    - '!file_permissions_user_cfg'
    - '!grub2_admin_username'
    - '!grub2_uefi_admin_username'
    - '!package_rsh_removed'
    - '!package_rsh-server_removed'
    - '!package_talk_removed'
    - '!package_talk-server_removed'
    - '!package_xinetd_removed'
    - '!package_ypbind_removed'
    - '!package_ypserv_removed'
    - '!rpm_verify_permissions'
    - '!service_crond_enabled'
    - '!service_rexec_disabled'
    - '!service_rlogin_disabled'
    - '!service_rsh_disabled'
    - '!service_ypbind_disabled'
    - '!service_zebra_disabled'
    - '!sshd_disable_rhosts_rsa'
    - '!sshd_use_approved_ciphers'
    - '!sshd_use_approved_macs'
