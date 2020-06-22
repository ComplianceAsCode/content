documentation_complete: true

title: 'Webmin STIG'

description: |-
    Webmin is a web-based interface for system administration for Unix. 
    Using any modern web browser, you can setup user accounts, Apache, 
    DNS, file sharing and much more. Webmin removes the need to manually 
    edit Unix configuration files like /etc/passwd, and lets you manage 
    a system from the console or remotely. This section provides settings 
    for configuring Webmin policies to meet compliance requirements for 
    Webmin running on Red Hat Enterprise Linux systems.

selections:
    - var_webmin_module_useradmin_accounts_inactive=35
    - var_webmin_module_useradmin_accounts_max=60
    - var_webmin_module_useradmin_accounts_min=1
    - var_webmin_module_useradmin_accounts_min_length=14
    - var_webmin_module_useradmin_accounts_password_hash=SHA512
    - var_webmin_module_useradmin_accounts_warn=7
    - var_webmin_sessions_login_banner_text=dod_default
    - var_webmin_sessions_port=15000
    - var_webmin_sessions_timeout=15
    - webmin_accounts_passwd_cmd
    - webmin_accounts_passwd_mode
    - webmin_accounts_use_pam
    - webmin_is_up_to_date
    - webmin_logs_webmin_actions_cleared
    - webmin_logs_webmin_actions_enabled
    - webmin_logs_webmin_actions_perms
    - webmin_logs_webmin_requests_cleared
    - webmin_logs_webmin_requests_enabled
    - webmin_logs_webmin_requests_perms
    - webmin_module_useradmin_accounts_char_types
    - webmin_module_useradmin_accounts_home_perms
    - webmin_module_useradmin_accounts_inactive
    - webmin_module_useradmin_accounts_last_login
    - webmin_module_useradmin_accounts_max
    - webmin_module_useradmin_accounts_min
    - webmin_module_useradmin_accounts_min_length
    - webmin_module_useradmin_accounts_password_dictionary
    - webmin_module_useradmin_accounts_password_hash
    - webmin_module_useradmin_accounts_password_masked
    - webmin_module_useradmin_accounts_password_same
    - webmin_module_useradmin_accounts_warn
    - webmin_sessions_login_banner
    - webmin_sessions_port
    - webmin_sessions_save_password
    - webmin_sessions_ssl_cipher
    - webmin_sessions_ssl_enabled
    - webmin_sessions_timeout
