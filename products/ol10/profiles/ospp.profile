documentation_complete: true

reference: https://www.niap-ccevs.org/Profile/Info.cfm?PPID=469&id=469

title: 'DRAFT - Protection Profile for General Purpose Operating Systems'

description: |-
    This is draft profile is based on the Oracle Linux 9 Common Criteria Guidance as
    guidance for Oracle Linux 10 was not available at the time of release.


    Where appropriate, CNSSI 1253 or DoD-specific values are used for
    configuration, based on Configuration Annex to the OSPP.

selections:
    - ospp:all

    - '!package_screen_installed'
    - '!package_dnf-plugin-subscription-manager_installed'
    - '!enable_dracut_fips_module'
    - '!package_subscription-manager_installed'

    - '!audit_access_success_aarch64.role=unscored'
    - '!audit_access_success_aarch64.severity=info'
    - '!audit_access_success_aarch64'
    - '!audit_access_success_ppc64le.role=unscored'
    - '!audit_access_success_ppc64le.severity=info'
    - '!audit_access_success_ppc64le'
    - '!audit_access_failed_aarch64'
    - '!audit_access_failed_ppc64le'
    - '!audit_create_failed_aarch64'
    - '!audit_create_failed_ppc64le'
    - '!audit_create_success_aarch64'
    - '!audit_create_success_ppc64le'
    - '!audit_delete_failed_aarch64'
    - '!audit_delete_failed_ppc64le'
    - '!audit_delete_success_aarch64'
    - '!audit_delete_success_ppc64le'
    - '!audit_modify_failed_aarch64'
    - '!audit_modify_failed_ppc64le'
    - '!audit_modify_success_aarch64'
    - '!audit_modify_success_ppc64le'
    - '!audit_module_load_ppc64le'
    - '!audit_ospp_general_aarch64'
    - '!audit_ospp_general_ppc64le'
    - '!audit_owner_change_failed_aarch64'
    - '!audit_owner_change_failed_ppc64le'
    - '!audit_owner_change_success_aarch64'
    - '!audit_owner_change_success_ppc64le'
    - '!audit_perm_change_failed_aarch64'
    - '!audit_perm_change_failed_ppc64le'
    - '!audit_perm_change_success_aarch64'
    - '!audit_perm_change_success_ppc64le'
    - '!ensure_redhat_gpgkey_installed'
    - 'ensure_oracle_gpgkey_installed'
    - '!zipl_audit_argument'
    - '!zipl_audit_backlog_limit_argument'
    - '!zipl_bls_entries_only'
    - '!zipl_bootmap_is_up_to_date'
    - '!zipl_init_on_alloc_argument'
    - '!zipl_page_alloc_shuffle_argument'
    - '!zipl_systemd_debug-shell_argument_absent'
