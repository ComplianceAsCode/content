documentation_complete: true

title: 'RHEL OSP STIG'

description: 'Sample profile description.'

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
    - keystone_file_ownership
    - keystone_file_perms
    - keystone_use_ssl
    - keystone_algorithm_hashing
    - keystone_max_request_body_size
    - keystone_disable_admin_token
    - keystone_lockout_failure_attempts
    - var_keystone_lockout_failure_attempts=3
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
