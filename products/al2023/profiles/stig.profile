documentation_complete: true

metadata:
    version: V1R1
    SMEs:
        - bordencastle
        - Eric-Domeier

reference: https://www.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'DISA STIG for Amazon Linux 2023'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG (Security Technical Implementation Guide) for Amazon Linux 2023.

    DISA STIGs are the configuration standards for DOD IA and IA-enabled
    devices/systems. The requirements are derived from the NIST 800-53
    and related documents.

selections:
    - stig_al2023:all
    - aide_use_fips_hashes
    - aide_build_database
    - audit_rules_time_adjtimex
    - audit_rules_time_settimeofday
    - audit_rules_time_stime
    - audit_rules_time_clock_settime
    - audit_rules_time_watch_localtime
    - audit_rules_usergroup_modification
    - audit_rules_networkconfig_modification
    - audit_rules_mac_modification
    - audit_rules_dac_modification_chmod
    - audit_rules_dac_modification_chown
    - audit_rules_dac_modification_fchmod
    - audit_rules_dac_modification_fchmodat
    - audit_rules_dac_modification_fchown
    - audit_rules_dac_modification_fchownat
    - audit_rules_dac_modification_fremovexattr
    - audit_rules_dac_modification_fsetxattr
    - audit_rules_dac_modification_lchown
    - audit_rules_dac_modification_lremovexattr
    - audit_rules_dac_modification_lsetxattr
    - audit_rules_dac_modification_removexattr
    - audit_rules_dac_modification_setxattr
    - audit_rules_unsuccessful_file_modification
    - audit_rules_privileged_commands
    - audit_rules_media_export
    - audit_rules_file_deletion_events
    - audit_rules_sysadmin_actions
    - audit_rules_kernel_module_loading
    - audit_rules_immutable_login_uids
    - mount_option_boot_efi_nosuid
    - grub2_audit_backlog_limit_argument
    - grub2_audit_argument
    - file_permissions_var_log_audit
    - rsyslog_logging_configured
    
