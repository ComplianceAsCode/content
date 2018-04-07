documentation_complete: true

title: '[DRAFT] DISA STIG for Apache HTTP on Red Hat Enterprise Linux 7'

description: |-
    This profile contains configuration checks that align to the
    DISA STIG for Apache HTTP web server.

selections:
    - httpd_enable_error_logging
    - httpd_configure_log_format
    - httpd_enable_system_logging
    - httpd_enable_loglevel
    - httpd_configure_max_keepalive_requests
    - httpd_enable_log_config
    - httpd_disable_anonymous_ftp_access
    - httpd_ignore_htaccess_files
    - httpd_anonymous_content_sharing
    - httpd_configure_script_permissions
    - httpd_configure_tls
    - httpd_require_client_certs
    - httpd_configure_valid_server_cert
    - httpd_configure_perl_taint
    - httpd_configure_remote_session_encryption
    - httpd_antivirus_scan_uploads
    - dir_perms_var_log_httpd
    - http_configure_log_file_ownership
    - httpd_configure_firewalld
    - httpd_configure_documentroot
    - partition_for_web_content
    - httpd_encrypt_file_uploads
    - httpd_configure_banner_page
    - httpd_remove_robots_file
    - httpd_disable_content_symlinks
    - httpd_limit_java_files
