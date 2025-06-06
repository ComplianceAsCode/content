documentation_complete: true

reference: https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux

title: 'General profile for SUSE Linux Enterprise Micro (SLEM) 6'

description: |-
    This profile contains configuration checks that align to the
    for SUSE Linux Enterprise Micro (SLEM) 6.

selections:
  - stig_slmicro5:all
  - var_user_initialization_files_regex=all_dotfiles
  - '!accounts_passwords_pam_tally2'
  - '!accounts_passwords_pam_tally2_file'
  - '!accounts_passwords_pam_tally2_file_selinux'
  - '!gnome_gdm_disable_unattended_automatic_login'
 
