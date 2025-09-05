documentation_complete: true

title: 'Upstream Firefox STIG'

description: |-
    This profile is developed under the DoD consensus model and DISA FSO Vendor STIG process,
    serving as the upstream development environment for the Firefox STIG.

    As a result of the upstream/downstream relationship between the SCAP Security Guide project
    and the official DISA FSO STIG baseline, users should expect variance between SSG and DISA FSO content.
    For official DISA FSO STIG content, refer to https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=app-security%2Cbrowser-guidance.

    While this profile is packaged by Red Hat as part of the SCAP Security Guide package, please note
    that commercial support of this SCAP content is NOT available. This profile is provided as example
    SCAP content with no endorsement for suitability or production readiness. Support for this
    profile is provided by the upstream SCAP Security Guide community on a best-effort basis. The
    upstream project homepage is https://www.open-scap.org/security-policies/scap-security-guide/.

selections:
    - var_default_home_page=about_blank
    - firefox_preferences-dod_root_certificate_installed
    - firefox_preferences-enable_ca_trust
    - firefox_preferences-addons_plugin_updates
    - firefox_preferences-auto-download_actions
    - firefox_preferences-autofill_forms
    - firefox_preferences-autofill_passwords
    - firefox_preferences-background_data
    - firefox_preferences-development_tools
    - firefox_preferences-dod_root_certificate_installed
    - firefox_preferences-enable_ca_trust
    - firefox_preferences-install_extensions
    - firefox_preferences-javascript_context_menus
    - firefox_preferences-javascript_window_changes
    - firefox_preferences-javascript_window_resizing
    - firefox_preferences-lock_settings_obscure
    - firefox_preferences-lock_settings_config_file
    - firefox_preferences-open_confirmation
    - firefox_preferences-password_store
    - firefox_preferences-pop-up_windows
    - firefox_preferences-search_update
    - firefox_preferences-shell_protocol
    - firefox_preferences-ssl_protocol_tls
    - firefox_preferences-verification
    - installed_firefox_version_supported
