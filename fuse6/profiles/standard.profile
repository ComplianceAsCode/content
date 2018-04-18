documentation_complete: true

title: 'Standard System Security Profile for JBoss'

description: |-
    This profile contains rules to ensure standard security baseline
    of JBoss Fuse. Regardless of your system's workload
    all of these checks should pass.

selections:
    - jboss_activemq-default_users_removed
    - jboss_activemq-default_roles_removed
    - jboss_activemq-java_aaa_service
    - jboss_activemq-cleartext_passwords
    - jboss_activemq-security_config_attributes
    - jboss_activemq-ssl_enabled
    - jboss_activemq-encrypted_passwords
    - jboss_activemq-pki_web_console
    - jboss_activemq-pki_dod_certificates
    - jboss_activemq-file_permissions
    - jboss_karaf-physical_protections
    - jboss_karaf-assign_administator
    - jboss_karaf-incident_response
    - jboss_karaf-incident_response_exercises
    - jboss_karaf-disaster_recovery
    - jboss_karaf-disaster_recovery_exerises
    - jboss_karaf-application_data_flow_docs
    - jboss_karaf-deployed_apps-java_perm_docs
    - jboss_karaf-backup_schedule
    - jboss_karaf-auditing_policy
    - jboss_karaf-access_control_docs
    - jboss_karaf-password_length_policy
    - jboss_karaf-password_complexity_policy
    - jboss_karaf-password_expiration_policy
    - jboss_karaf-vender_supported_version
    - jboss_karaf-java_vendor_supported
    - jboss_karaf-downloaded_software_valid
    - jboss_karaf-disable_hot_deployment
    - jboss_karaf-remove_default_users
    - jboss_karaf-remove_default_roles
    - jboss_karaf-secure_java_security_manager
    - jboss_karaf-deployed_java_file_permissions
    - jboss_karaf-deployed_java_network_permissions
    - jboss_karaf-deployed_runtime_permissions
    - jboss_karaf-deployed_socket_permissions
    - jboss_karaf-deployed_permissions
    - jboss_karaf-java_aaa_service
    - jboss_karaf-dod_hardware_pki_token
    - jboss_karaf-enable_fips_modules
    - jboss_karaf-remove_cleartext_passwords
    - jboss_karaf-process_owner_permissions
    - jboss_karaf-process_owner_console_access
    - jboss_karaf-files_ownership
    - jboss_karaf-file_permissions
    - jboss_karaf-secure_remote_access
    - jboss_karaf-secure_web_console
    - jboss_karaf-secure_jmx_access
    - jboss_karaf-enable_encrypted_passwords
    - jboss_karaf-security_config_attributes
    - jboss_karaf-pki_assocation_permission
    - jboss_karaf-enable_ssl
    - jboss_karaf-enable_secure_connections
    - jboss_karaf-reduce_logging
    - jboss_karaf-log_retention
    - jboss_karaf-system_admin_access
    - jboss_karaf-non-essential_bundles_features
    - jboss_karaf-disable_services_ports
    - jboss_karaf-stored_passwords_encrypted
    - jboss_karaf-enable_ldap_ssl
    - jboss_karaf-enable_fips_authentication
    - jboss_karaf-dod_cns_certificates
    - jboss_karaf-ldap_securely_fail
    - jboss_karaf-secure_logging
    - jboss_karaf-logging_access
    - jboss_karaf-enable_pki_web_console
    - jboss_karaf-valid_dod_certificates
    - jboss_karaf-config_file_permissions
