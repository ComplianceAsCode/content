documentation_complete: true

title: 'STIG for JBoss Enterprise Application Platform 6'

description: 'This is a *draft* profile for STIG. This profile is being developed under the DoD consensus model to become
    a STIG in coordination with DISA FSO.'

selections:
    - var_jboss_profile=default
    - jboss_eap_configure_secure_management_access
    - jboss_eap_configure_https
    - jboss_eap_configure_host_access_restrictions
    - jboss_eap_configure_security_manager
    - jboss_eap_enable_rbac
    - jboss_eap_configure_user_roles
    - jboss_eap_configure_application_authentication
    - jboss_eap_configure_management_authentication
    - jboss_eap_configure_security_realm
    - jboss_eap_configure_auditing
    - jboss_eap_configure_auditor_roles
    - jboss_eap_configure_logging_level
    - jboss_eap_configure_log_permissions
    - jboss_eap_configure_offloading_max
    - jboss_eap_configure_user_permissions
    - jboss_eap_restrict_jboss_account
    - jboss_eap_disable_analytics
    - jboss_eap_unprivileged_mode
    - jboss_eap_remove_quickstarts
    - jboss_eap_remove_jmx
    - jboss_eap_disable_replace_welcome_page
    - jboss_eap_remove_unnecessary_apps
    - jboss_eap_configure_ports
    - jboss_eap_configure_ldap
    - jboss_eap_configure_multifactor_authentication
    - jboss_eap_remove_group_accounts
    - jboss_eap_configure_management_network
    - jboss_eap_configure_management_ldap
    - jboss_eap_configure_keystore
    - jboss_eap_encrypt_keystore_passwords
    - jboss_eap_require_password_access
    - jboss_eap_use_secure_ldap_port
    - jboss_eap_secure_keystore_permissions
    - jboss_eap_service_separate_networks
    - jboss_eap_file_permissions
    - jboss_eap_logs_permissions
    - jboss_eap_disable_domain_admin_console
    - jboss_eap_audit_privileged_actions
    - jboss_eap_configure_syslog
    - jboss_eap_disable_automatic_deployment
    - jboss_eap_log_deployments
    - jboss_eap_use_approved_ca_cert
    - jboss_eap_configure_ha_lb
    - jboss_eap_use_tls
    - jboss_eap_use_approved_ciphers
    - jboss_eap_vendor_supported
    - jboss_eap_system_up_to_date
    - jboss_eap_use_dod_approved_certs
    - jboss_eap_roll_over_transfer_logs
