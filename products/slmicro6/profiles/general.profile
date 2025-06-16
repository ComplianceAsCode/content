documentation_complete: true

reference: not_publicly_available

title: 'General profile for SUSE Linux Enterprise Micro (SLEM) 6'

description: |-
    This profile contains configuration checks that align to the
    for SUSE Linux Enterprise Micro (SLEM) 6.

selections:
  - stig_slmicro5:all
  - var_user_initialization_files_regex=all_dotfiles
  - var_accounts_authorized_local_users_regex=slmicro6
  - '!accounts_passwords_pam_tally2'
  - '!accounts_passwords_pam_tally2_file'
  - '!accounts_passwords_pam_tally2_file_selinux'
  - '!gnome_gdm_disable_unattended_automatic_login'
  - '!partition_for_var_log_audit'
  - '!pam_disable_automatic_configuration'
  - '!mount_option_nosuid_remote_filesystems'
  - '!mount_option_noexec_remote_filesystems'
  - '!service_autofs_disabled'
  - '!grub2_password'
  - '!grub2_uefi_password'
