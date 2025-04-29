documentation_complete: true

hidden: true

title: Default Profile for Red Hat Enterprise Linux 10

description: |-
  This profile contains all the rules that once belonged to the rhel10
  product. This profile won't be rendered into an XCCDF Profile entity,
  nor it will select any of these rules by default. The only purpose of
  this profile is to keep a rule in the product's XCCDF Benchmark.

selections:
  - grub2_nousb_argument
  - audit_rules_kernel_module_loading_create
  - grub2_uefi_admin_username
  - grub2_uefi_password
  - no_tmux_in_shells
  - package_tmux_installed
  - configure_tmux_lock_after_time
  - configure_tmux_lock_command
  - configure_tmux_lock_keybinding
  - audit_rules_session_events
  - enable_authselect
  - audit_rules_login_events
  - audit_rules_unsuccessful_file_modification
  - configure_openssl_tls_crypto_policy
  - audit_rules_privileged_commands_pt_chown
  - package_iprutils_removed
  - service_rlogin_disabled
  - service_rsh_disabled
