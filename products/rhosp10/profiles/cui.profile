documentation_complete: true

title: '[DRAFT] Controlled Unclassified Infomration (CUI) Profile for Red Hat OpenStack Plaform 10'

description: 'These are the controls for scanning against CUI for rhosp10'

selections:
    - horizon_file_ownership
    - horizon_file_perms
    - horizon_use_ssl
    - horizon_csrf_cookie_secure
    - horizon_session_cookie_secure
    - horizon_session_cookie_httponly
    - horizon_password_autocomplete
    - horizon_disable_password_reveal
    - cinder_file_ownership
    - cinder_conf_file_perms
    - cinder_file_perms
    - cinder_using_keystone
    - cinder_tls_enabled
    - cinder_nova_tls
    - cinder_glance_tls
    - cinder_nas_secure_file_permissions
    - cinder_osapi_max_request_body
    #
    # Keystone Rules
    #
    - var_keystone_lockout_failure_attempts=3
    - var_keystone_lockout_duration=15_minutes
    - var_keystone_disable_user_account_days_inactive=90

    - keystone_file_ownership
    - keystone_file_perms
    - keystone_use_ssl
    - keystone_algorithm_hashing
    - keystone_max_request_body_size
    - keystone_disable_admin_token
    - keystone_lockout_failure_attempts
    - keystone_lockout_duration
    - keystone_disable_user_account_days_inactive
    #
    # Neutron Rules
    #
    - neutron_file_ownership
    - neutron_file_perms
    - neutron_use_keystone
    - neutron_use_https
    - neutron_api_use_ssl
    - nova_file_ownership
    - nova_file_perms
    - nova_use_keystone
    - nova_secure_authentication
    - nova_secure_glance
