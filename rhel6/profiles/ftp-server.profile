documentation_complete: true

title: 'FTP Server Profile (vsftpd)'

description: 'This is a profile for the vsftpd FTP server.'

extends: server

selections:
    - package_vsftpd_installed
    - ftp_log_transactions
    - ftp_present_banner
    - ftp_restrict_to_anon
    - ftp_disable_uploads
    - ftp_home_partition
